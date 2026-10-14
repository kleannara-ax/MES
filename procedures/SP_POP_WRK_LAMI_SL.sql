
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK_LAMI_SL" SP_POP_WRK_LAMI_SL
(
    P_WRK_ORDR_NO        IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO    IN VARCHAR2 
    ,P_MACH_CD    IN VARCHAR2 
    ,P_IOTYPE    IN VARCHAR2 
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
    ,CUR_2       OUT SYS_REFCURSOR
    ,CUR_3       OUT SYS_REFCURSOR
    ,CUR_4       OUT SYS_REFCURSOR
    ,CUR_5       OUT SYS_REFCURSOR    
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅 작업지시
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 작업지시를 보여주기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK_LAMI_SL';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);
    V_COLINFO1 VARCHAR2(1000);
    V_COLTYPE1 VARCHAR2(1000);   
    V_DATE DATE := SYSDATE;
    V_ABN_STA NUMBER;
    V_LAMI_PC_DVI NUMBER := 0; 
    V_LAMI_SL_DVI NUMBER := 0; 
    V_LAMI_PC_RES NUMBER := 0; 
    V_LAMI_SL_RES NUMBER := 0; 
    V_MAT_INPUT_CNT NUMBER := 0;
    -- 작업지시번호, 순번 변수
    V_WRK_ORDR_NO		VARCHAR2(20);
    V_WRK_ORDR_SEQNO	VARCHAR2(20);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
	        BEGIN
		        SELECT	WRK_ORDR_NO, WRK_ORDR_SEQNO
		        		INTO	V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
		        FROM	TB_WRK011
		        WHERE	MACH_CD = P_MACH_CD;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_ORDR_NO := '';
                    V_WRK_ORDR_SEQNO := '';
		    END;
        DBMS_OUTPUT.put_line('V_WRK_ORDR_NO = ' || V_WRK_ORDR_NO);
        DBMS_OUTPUT.put_line('V_WRK_ORDR_SEQNO = ' || V_WRK_ORDR_SEQNO);
	        --비가동 여부 확인
	        SELECT COUNT(*)
	          INTO V_ABN_STA
			  FROM TB_WRK003
			 WHERE 1=1
			   AND MACH_CD  = P_MACH_CD
               AND CNL_YN = 'N'
			   AND V_DATE BETWEEN STR_DATE AND NVL(END_DATE,V_DATE) ;

        IF P_MACH_CD = 'PLP01' THEN
            BEGIN
                SELECT NVL(COUNT(*),0)
                  INTO V_LAMI_PC_DVI
                  FROM TB_LAMI_PC
                 WHERE 1 = 1
                   AND MACH_CD = P_MACH_CD
                   AND USE_YN  = 'Y'
                   AND COMP_YN IN ('I','N')
    --			   AND V_DATE BETWEEN PRD_STR_DATE AND END_DATE 
                   ;
                V_LAMI_SL_DVI := 0;
            END;
        ELSIF P_MACH_CD = 'PLS01' THEN
            BEGIN
                SELECT NVL(COUNT(*),0)
                  INTO V_LAMI_SL_DVI
                  FROM TB_LAMI_SL
                 WHERE 1 = 1
                   AND MACH_CD = P_MACH_CD
                   AND USE_YN  = 'Y'
                   AND COMP_YN IN ('I','N')
    --			   AND V_DATE BETWEEN PRD_STR_DATE AND END_DATE 
                   ;
                V_LAMI_PC_DVI := 0;
            END;
        END IF;

        DBMS_OUTPUT.put_line('V_LAMI_SL_DVI = ' || V_LAMI_SL_DVI);
       
        SELECT COUNT(*)
        INTO V_MAT_INPUT_CNT
        FROM TB_INV003
        WHERE 1 = 1
        AND WRK_ORDR_NO = V_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
        ;
        DBMS_OUTPUT.put_line('V_MAT_INPUT_CNT = ' || V_MAT_INPUT_CNT);

			IF V_LAMI_PC_DVI > 0 AND P_MACH_CD = 'PLP01' THEN
				BEGIN
					SELECT NVL(COUNT(*),0)
					  INTO V_LAMI_PC_RES
					  FROM TB_LAMI_PC A
					  INNER JOIN TB_LAMI_PC_RESULT B ON A.WERKS = B.WERKS AND A.WRK_ORDR_NO = B.WRK_ORDR_NO AND A.MACH_CD = B.MACH_CD AND B.USE_YN = 'Y' AND B.SL_MOVE_YN = 'Y'
					 WHERE 1 = 1
					   AND A.MACH_CD = P_MACH_CD
					   AND A.USE_YN  = 'Y'
                       AND A.COMP_YN IN ('I','N')
                       AND A.WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND A.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
					   ;
                    V_LAMI_SL_RES := 0;
			    END;
			END IF;

			IF V_LAMI_SL_DVI > 0 AND P_MACH_CD = 'PLS01' THEN
				BEGIN
                    SELECT NVL(COUNT(*),0) AS CNT
                    INTO V_LAMI_SL_RES
                      FROM TB_LAMI_SL A
                      INNER JOIN TB_LAMI_SL_RESULT B ON A.WERKS = B.WERKS AND A.WRK_ORDR_NO = B.WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO AND A.MACHINE = B.MACH_CD
                     WHERE 1 = 1
                       AND A.MACHINE = 'PLS01'
                       AND A.USE_YN  = 'Y'
                       AND A.WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND A.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
					   ;
                    V_LAMI_PC_RES := 0;
        DBMS_OUTPUT.put_line('V_LAMI_SL_RES = ' || V_LAMI_SL_RES);
			    END;
			END IF;

            --grid 컬럼 정보 설정
            V_COLINFO := '생산요청일@C^120|작업지시번호@H|순번@H|품목코드@C^200|품목명@L^400|계획량@R^100|단위@C^70|지시사항@L^600|상태@H|상세보기@H|표시순번@H|작업순번@H';
            V_COLTYPE := 'PRD_REQ_DT@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|STA@varchar|WRK_ORDR_RMK@varchar|WRK_ORDR_DETAIL@Button|ROWSEQ@varchar|WRK_SEQNO@varchar';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        DBMS_OUTPUT.put_line('=================================================================');
        DBMS_OUTPUT.put_line('V_LAMI_PC_DVI = ' || V_LAMI_PC_DVI);
        DBMS_OUTPUT.put_line('V_LAMI_PC_RES = ' || V_LAMI_PC_RES);
        DBMS_OUTPUT.put_line('V_LAMI_SL_DVI = ' || V_LAMI_SL_DVI);
			IF V_LAMI_PC_DVI > 0 AND V_LAMI_PC_RES = 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
					SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
						 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
						 , S012.WRK_ORDR_SEQNO      --작업지시 순번
						 , S012.MATNR               --자재코드
						 , M001.MATNR_NM            --자재명
						 , TO_CHAR(S012.REMAIN_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
						 , S012.UNIT                --단위
						 , S012.WRK_ORDR_RMK        --작업지시사항
						 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
								WHEN S012.COMP_YN = 'I' THEN '가동중' 
								WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
						 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
						 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
						 , S012.WRK_SEQNO
					FROM TB_LAMI_PC S012, --화장지 가공기 작업지시
						 TB_MAS001 M001, --자재정보
						 (SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
					WHERE 1=1
					AND ROWNUM < 10
					AND S012.WERKS = M001.WERKS(+)
					AND S012.MATNR = M001.MATNR(+)
					AND S012.MACH_CD = W011.MACH_CD(+)
					AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
					AND S012.MACH_CD = P_MACH_CD
					AND S012.COMP_YN != 'Y'
					AND (S012.COMP_YN = 'I' OR TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD') > (V_DATE - INTERVAL '14' DAY))
					ORDER BY ROWSEQ, S012.PRD_REQ_DT, S012.WRK_SEQNO, S012.WRK_ORDR_NO, S012.WRK_ORDR_SEQNO;
				END;
			ELSIF V_LAMI_PC_DVI > 0 AND V_LAMI_PC_RES > 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
                SELECT PRD_REQ_DT       --생산지시일
                     , WRK_ORDR_NO --작업지시
                     , WRK_ORDR_SEQNO      --작업지시 순번
                     , MATNR               --자재코드
                     , MATNR_NM            --자재명
                     , WRK_ORDR_QTY --지시수량
                     , UNIT                --단위
                     , WRK_ORDR_RMK        --작업지시사항
                     , WRK_ORDR_DETAIL    --상세보기
                     , ROWSEQ
                     , WRK_SEQNO
                     FROM (
                            SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                                 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
                                 , S012.WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , TO_CHAR(S012.REMAIN_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                                 , S012.UNIT                --단위
                                 , S012.WRK_ORDR_RMK        --작업지시사항
                                 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
                                        WHEN S012.COMP_YN = 'I' THEN '가동중' 
                                        WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
                                 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
                                 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
                                 , S012.WRK_SEQNO
                            FROM TB_LAMI_PC S012 --화장지 가공기 작업지시
                                 ,TB_MAS001 M001 --자재정보
                                 ,(SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
                            WHERE 1=1
                            AND ROWNUM < 10
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND S012.MACH_CD = W011.MACH_CD(+)
                            AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
                            AND S012.MACH_CD = P_MACH_CD
                            AND S012.COMP_YN != 'Y'
                    )
                    ORDER BY ROWSEQ, PRD_REQ_DT, WRK_SEQNO,WRK_ORDR_NO, WRK_ORDR_SEQNO;
				END;
			ELSIF V_LAMI_PC_DVI = 0 AND V_LAMI_PC_RES = 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
                SELECT PRD_REQ_DT       --생산지시일
                     , WRK_ORDR_NO --작업지시
                     , WRK_ORDR_SEQNO      --작업지시 순번
                     , MATNR               --자재코드
                     , MATNR_NM            --자재명
                     , WRK_ORDR_QTY --지시수량
                     , UNIT                --단위
                     , WRK_ORDR_RMK        --작업지시사항
                     , WRK_ORDR_DETAIL    --상세보기
                     , ROWSEQ
                     , WRK_SEQNO
                     FROM (
                            SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                                 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
                                 , S012.WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , TO_CHAR(S012.REMAIN_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                                 , S012.UNIT                --단위
                                 , S012.WRK_ORDR_RMK        --작업지시사항
                                 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
                                        WHEN S012.COMP_YN = 'I' THEN '가동중' 
                                        WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
                                 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
                                 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
                                 , S012.WRK_SEQNO
                            FROM TB_LAMI_PC S012 --화장지 가공기 작업지시
                                 ,TB_MAS001 M001 --자재정보
                                 ,(SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
                            WHERE 1=1
                            AND ROWNUM < 10
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND S012.MACH_CD = W011.MACH_CD(+)
                            AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
                            AND S012.MACH_CD = P_MACH_CD
                            AND S012.COMP_YN != 'Y'
                    )
                    ORDER BY ROWSEQ, PRD_REQ_DT, WRK_SEQNO,WRK_ORDR_NO, WRK_ORDR_SEQNO;
				END;
			ELSIF V_LAMI_SL_DVI > 0 AND V_LAMI_SL_RES = 0 AND V_LAMI_PC_DVI = 0  THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
					SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
						 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
						 , S012.WRK_ORDR_SEQNO      --작업지시 순번
						 , S012.MATNR               --자재코드
						 , M001.MATNR_NM            --자재명
						 , TO_CHAR(S012.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
						 , S012.UNIT                --단위
						 , S012.WRK_ORDR_RMK        --작업지시사항
						 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
								WHEN S012.COMP_YN = 'I' THEN '가동중' 
								WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
						 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
						 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
						 , S012.WRK_SEQNO
					FROM TB_LAMI_SL S012, --화장지 가공기 작업지시
						 TB_MAS001 M001, --자재정보
						 (SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
					WHERE 1=1
					AND ROWNUM < 10
					AND S012.WERKS = M001.WERKS(+)
					AND S012.MATNR = M001.MATNR(+)
					AND S012.MACHINE = W011.MACH_CD(+)
					AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
					AND S012.MACH_CD = P_MACH_CD
					AND S012.COMP_YN != 'Y'
					AND (S012.COMP_YN = 'I' OR TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD') > (V_DATE - INTERVAL '14' DAY))
					ORDER BY ROWSEQ, S012.PRD_REQ_DT, S012.WRK_SEQNO, S012.WRK_ORDR_NO, S012.WRK_ORDR_SEQNO;
				END;
			ELSIF V_LAMI_SL_DVI > 0 AND V_LAMI_SL_RES > 0 AND V_LAMI_PC_DVI = 0  THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
					SELECT PRD_REQ_DT       --생산지시일
						 , WRK_ORDR_NO --작업지시
						 , WRK_ORDR_SEQNO      --작업지시 순번
						 , MATNR               --자재코드
						 , MATNR_NM            --자재명
						 , WRK_ORDR_QTY --지시수량
						 , UNIT                --단위
						 , WRK_ORDR_RMK        --작업지시사항
						 , STA               --작업지시 상태
						 , WRK_ORDR_DETAIL    --상세보기
						 , ROWSEQ
						 , WRK_SEQNO
                         FROM (
                            SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                                 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
                                 , S012.WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , TO_CHAR(S012.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                                 , S012.UNIT                --단위
                                 , S012.WRK_ORDR_RMK        --작업지시사항
                                 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
                                        WHEN S012.COMP_YN = 'I' THEN '가동중' 
                                        WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
                                 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
                                 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
                                 , S012.WRK_SEQNO
                            FROM TB_LAMI_SL S012, --화장지 가공기 작업지시
                                 TB_MAS001 M001 --자재정보
                                 ,(SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
                            WHERE 1=1
                            AND ROWNUM < 10
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND S012.MACHINE = W011.MACH_CD(+)
                            AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
                            AND S012.MACH_CD = P_MACH_CD
                            AND S012.COMP_YN != 'Y'
                    ) A
                    WHERE 1 = 1
--					AND (S012.COMP_YN = 'I' OR TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD') > (V_DATE - INTERVAL '14' DAY))
					ORDER BY ROWSEQ, PRD_REQ_DT, WRK_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO
                    ;
				END;
			ELSIF V_LAMI_SL_DVI = 0 AND V_LAMI_SL_RES = 0 AND  V_LAMI_PC_DVI = 0  THEN
				BEGIN
					--화장지 지시목록 조회
					OPEN CUR_2 FOR
					SELECT TO_CHAR(TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
						 , S012.WRK_ORDR_NO || '-' || LPAD(S012.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO --작업지시
						 , S012.WRK_ORDR_SEQNO      --작업지시 순번
						 , S012.MATNR               --자재코드
						 , M001.MATNR_NM            --자재명
						 , TO_CHAR(S012.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
						 , S012.UNIT                --단위
						 , S012.WRK_ORDR_RMK        --작업지시사항
						 , CASE WHEN S012.COMP_YN = 'N' THEN '대기'
								WHEN S012.COMP_YN = 'I' THEN '가동중' 
								WHEN S012.COMP_YN = 'Y' THEN '완료' END AS STA               --작업지시 상태
						 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
						 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
						 , S012.WRK_SEQNO
					FROM TB_LAMI_SL S012, --화장지 가공기 작업지시
						 TB_MAS001 M001, --자재정보
						 (SELECT * FROM TB_WRK011 WHERE IN_OUT = 'I') W011
					WHERE 1=1
					AND ROWNUM < 10
					AND S012.WERKS = M001.WERKS(+)
					AND S012.MATNR = M001.MATNR(+)
					AND S012.MACHINE = W011.MACH_CD(+)
					AND S012.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
					AND S012.MACHINE = P_MACH_CD
					AND S012.COMP_YN != 'Y'
					AND (S012.COMP_YN = 'I' OR TO_DATE(S012.PRD_REQ_DT,'YYYYMMDD') > (V_DATE - INTERVAL '14' DAY))
					ORDER BY ROWSEQ, S012.PRD_REQ_DT, S012.WRK_SEQNO, S012.WRK_ORDR_NO, S012.WRK_ORDR_SEQNO;
				END;
			END IF;

			IF V_LAMI_PC_DVI > 0 AND V_LAMI_PC_RES = 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
				--현재 작업지시 조회
					OPEN CUR_3 FOR
					SELECT S012.PRD_REQ_DT         --생산지시일
						 , W011.WRK_ORDR_NO         --작업지시
						 , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
						 , S012.ORDER_NO            --생산오더
						 , S012.MATNR               --자재코드
						 , M001.MATNR_NM            --자재명
						 , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
						 , NVL(M001.WLEN,0) AS WLEN                --가로길이
						 , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
						 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY        --잔량
						 , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적수량
						 , S012.UNIT                --단위
						 , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
						 , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
						 , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
						 , S012.ORDER_RMK           --오더비고
						 , S012.SAL_RMK             --폐품비고
						 , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
						 , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                         , W011.MACH_STA AS ORG_MACH_STA                                --원가동 상태
                         , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_STR_DTM ELSE TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') END AS PRD_STR_DATE           -- 시작시간(지금시간)
						 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_END_DTM ELSE NULL END AS PRD_END_DATE --완료시간
						 , W002.WRK_SEQ
                         , '' AS DISPO_CD
                         , '' AS DISPO_NM
                         , S012.DLFL AS DLFL
					FROM TB_WRK011 W011,            --작업장 현황
						 TB_LAMI_PC S012,            --화장지 가공기 작업지시
						 TB_MAS001 M001,            --자재정보
						  TB_WRK002 W002
						  ,TB_MAS023 M023
					WHERE 1=1 
					AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
					AND S012.WERKS = M001.WERKS(+)
					AND S012.MATNR = M001.MATNR(+)
					AND W011.MACH_CD = P_MACH_CD
					AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
					AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
					AND W011.IN_OUT = P_IOTYPE
					AND W011.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
					AND S012.SALCODE = M023.DISPO_CD(+)
                    AND S012.WERKS = M023.WERKS(+)
					;
				END;
			ELSIF V_LAMI_PC_DVI > 0 AND V_LAMI_PC_RES > 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
					OPEN CUR_3 FOR
					SELECT PRD_REQ_DT         --생산지시일
						 , WRK_ORDR_NO         --작업지시
						 , WRK_ORDR_SEQNO      --작업지시 순번
						 , ORDER_NO            --생산오더
						 , MATNR               --자재코드
						 , MATNR_NM            --자재명
						 , BS_WGT              --평량
						 , WLEN                --가로길이
						 , WRK_ORDR_QTY        --계획수량
						 , REMAIN_QTY           --잔량
						 , PRFM_QTY            --실적수량
						 , UNIT                --단위
						 , SALWEIGHT           --폐품처리량
						 , PRFMMET_QTY       --실적미터
						 , SALMETER           --폐품미터
						 , ORDER_RMK           --오더비고
						 , SAL_RMK             --폐품비고
						 , WRK_ORDR_RMK   --작업지시사항
						 , MACH_STA           --가동여부
                         , ORG_MACH_STA       --원 가동여부
						 , PRD_STR_DATE --시작시간
						 , PRD_END_DATE --완료시간
						 , WRK_SEQNO
                         , DISPO_CD
                         , DISPO_NM
                         , DLFL
                         FROM (
                                SELECT NVL(S012.PRD_REQ_DT,TO_CHAR(SYSDATE,'YYYYMMDD')) AS   PRD_REQ_DT       --생산지시일
                                     , W011.WRK_ORDR_NO         --작업지시
                                     , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                     , S012.ORDER_NO            --생산오더
                                     , S012.MATNR               --자재코드
                                     , M001.MATNR_NM            --자재명
                                     , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                     , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                     , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
            						 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY        --잔량
                                     , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적수량
                                     , S012.UNIT                --단위
                                     , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                     , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                     , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                     , S012.ORDER_RMK           --오더비고
                                     , S012.SAL_RMK             --폐품비고
                                     , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                     , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부.
                                     , W011.MACH_STA AS ORG_MACH_STA                                --원가동 상태
                                     , CASE 
											WHEN DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') <> 'S' THEN
												(SELECT MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS')) FROM TB_LAMI_PC_RESULT
													WHERE WERKS = S012.WERKS 
													AND MACH_CD = S012.MACH_CD 
													AND WRK_ORDR_NO = S012.WRK_ORDR_NO 
													AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO 
													AND USE_YN = 'Y')
											ELSE
												S012.PRD_STR_DTM
										END AS PRD_STR_DATE  
                                     --, TO_DATE(S012.PRD_END_DTM,'YYYYMMDDHH24MISS') AS PRD_END_DATE --완료시간
                                     , S012.PRD_END_DTM AS PRD_END_DATE --완료시간
                                     , 1 AS WRK_SEQNO
                                     , '' AS DISPO_CD
                                     , '' AS DISPO_NM
                                     , S012.DLFL AS DLFL
                                FROM TB_WRK011 W011            --작업장 현황
                                     ,TB_LAMI_PC S012            --화장지 가공기 작업지시
                                     ,TB_MAS001 M001            --자재정보
                                      ,TB_MAS023 M023
                                WHERE 1=1 
                                AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                                AND S012.WERKS = M001.WERKS(+)
                                AND S012.MATNR = M001.MATNR(+)
                                AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                                AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                AND S012.MACH_CD = P_MACH_CD
                                AND W011.IN_OUT = P_IOTYPE
                                AND S012.USE_YN = 'Y'
                                AND S012.SALCODE = M023.DISPO_CD(+)
                                AND S012.WERKS = M023.WERKS(+)
                        ) A
                        GROUP BY
                          PRD_REQ_DT         --생산지시일
						 , WRK_ORDR_NO         --작업지시
						 , WRK_ORDR_SEQNO      --작업지시 순번
						 , ORDER_NO            --생산오더
						 , MATNR               --자재코드
						 , MATNR_NM            --자재명
						 , BS_WGT              --평량
						 , WLEN                --가로길이
						 , WRK_ORDR_QTY        --계획수량
						 , REMAIN_QTY           --잔량
						 , PRFM_QTY            --실적수량
						 , UNIT                --단위
						 , SALWEIGHT           --폐품처리량
						 , PRFMMET_QTY       --실적미터
						 , SALMETER           --폐품미터
						 , ORDER_RMK           --오더비고
						 , SAL_RMK             --폐품비고
						 , WRK_ORDR_RMK   --작업지시사항
						 , MACH_STA           --가동여부
                         , ORG_MACH_STA
						 , PRD_STR_DATE --시작시간
						 , PRD_END_DATE --완료시간
						 , WRK_SEQNO
                         , DISPO_CD
                         , DISPO_NM
                         , DLFL

					;
				END;
			ELSIF V_LAMI_PC_DVI = 0 AND V_LAMI_PC_RES = 0 AND V_LAMI_SL_DVI = 0 THEN
				BEGIN
					OPEN CUR_3 FOR
					SELECT PRD_REQ_DT         --생산지시일
						 , WRK_ORDR_NO         --작업지시
						 , WRK_ORDR_SEQNO      --작업지시 순번
						 , ORDER_NO            --생산오더
						 , MATNR               --자재코드
						 , MATNR_NM            --자재명
						 , BS_WGT              --평량
						 , WLEN                --가로길이
						 , WRK_ORDR_QTY        --계획수량
						 , REMAIN_QTY           --잔량
						 , PRFM_QTY            --실적수량
						 , UNIT                --단위
						 , SALWEIGHT           --폐품처리량
						 , PRFMMET_QTY       --실적미터
						 , SALMETER           --폐품미터
						 , ORDER_RMK           --오더비고
						 , SAL_RMK             --폐품비고
						 , WRK_ORDR_RMK   --작업지시사항
						 , MACH_STA           --가동여부
                         , ORG_MACH_STA       --원 가동여부
						 , PRD_STR_DATE --시작시간
						 , PRD_END_DATE --완료시간
						 , WRK_SEQNO
                         , DISPO_CD
                         , DISPO_NM
                         , DLFL
                         FROM (
                                SELECT S012.PRD_REQ_DT         --생산지시일
                                     , W011.WRK_ORDR_NO         --작업지시
                                     , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                     , S012.ORDER_NO            --생산오더
                                     , S012.MATNR               --자재코드
                                     , M001.MATNR_NM            --자재명
                                     , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                     , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                     , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
            						 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY        --잔량
                                     , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적수량
                                     , S012.UNIT                --단위
                                     , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                     , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                     , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                     , S012.ORDER_RMK           --오더비고
                                     , S012.SAL_RMK             --폐품비고
                                     , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                     , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부.
                                     , W011.MACH_STA AS ORG_MACH_STA                                --원가동 상태
                                     , CASE 
											WHEN DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') <> 'S' AND S012.DLFL != 'A' THEN
												(SELECT MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS')) FROM TB_LAMI_SL_RESULT
													WHERE WERKS = S012.WERKS 
													AND MACH_CD = S012.MACH_CD 
													AND WRK_ORDR_NO = S012.WRK_ORDR_NO 
													AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO 
													AND USE_YN = 'Y')
											ELSE
                                                CASE WHEN S012.DLFL = 'A' THEN S012.PRD_STR_DTM ELSE TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') END
										END AS PRD_STR_DATE  
                                     , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_END_DTM ELSE NULL END AS PRD_END_DATE --완료시간
                                     , 1 AS WRK_SEQNO
                                     , '' AS DISPO_CD
                                     , '' AS DISPO_NM
                                     , S012.DLFL AS DLFL
                                FROM TB_WRK011 W011            --작업장 현황
                                     ,TB_LAMI_PC S012            --화장지 가공기 작업지시
                                     ,TB_MAS001 M001            --자재정보
                                      ,TB_MAS023 M023
                                WHERE 1=1 
                                AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                                AND S012.WERKS = M001.WERKS(+)
                                AND S012.MATNR = M001.MATNR(+)
                                AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                                AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                AND S012.MACH_CD = P_MACH_CD
                                AND W011.IN_OUT = P_IOTYPE
                                AND S012.USE_YN = 'Y'
                                AND S012.SALCODE = M023.DISPO_CD(+)
                                AND S012.WERKS = M023.WERKS(+)
                        ) A
                        GROUP BY
                          PRD_REQ_DT         --생산지시일
						 , WRK_ORDR_NO         --작업지시
						 , WRK_ORDR_SEQNO      --작업지시 순번
						 , ORDER_NO            --생산오더
						 , MATNR               --자재코드
						 , MATNR_NM            --자재명
						 , BS_WGT              --평량
						 , WLEN                --가로길이
						 , WRK_ORDR_QTY        --계획수량
						 , REMAIN_QTY           --잔량
						 , PRFM_QTY            --실적수량
						 , UNIT                --단위
						 , SALWEIGHT           --폐품처리량
						 , PRFMMET_QTY       --실적미터
						 , SALMETER           --폐품미터
						 , ORDER_RMK           --오더비고
						 , SAL_RMK             --폐품비고
						 , WRK_ORDR_RMK   --작업지시사항
						 , MACH_STA           --가동여부
                         , ORG_MACH_STA
						 , PRD_STR_DATE --시작시간
						 , PRD_END_DATE --완료시간
						 , WRK_SEQNO
                         , DISPO_CD
                         , DISPO_NM
                         , DLFL
					;
				END;
			ELSIF V_LAMI_SL_DVI > 0 AND V_LAMI_SL_RES = 0 AND V_LAMI_PC_DVI = 0 THEN
				BEGIN
                    IF V_MAT_INPUT_CNT > 0 THEN
                        BEGIN
                            OPEN CUR_3 FOR
                            SELECT S012.PRD_REQ_DT         --생산지시일
                                 , S012.WRK_ORDR_NO         --작업지시
                                 , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.ORDER_NO            --생산오더
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , NVL(S020.MATNR,'') AS M_MATNR               --원자재코드
                                 , NVL(M002.MATNR_NM,'') AS M_MATNR_NM
                                 , NVL(S020.LOT_NO,'') AS M_LOT_NO               --원자재코드
                                 , '' AS M_IND_BCD               --원자재코드
                                 , NVL((SELECT SUM(IN_QTY) FROM TB_INV003
										WHERE WRK_ORDR_NO = S012.WRK_ORDR_NO
										AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO),0) AS M_IN_QTY
                                 , NVL(S020.ORDER_BOM_QTY,0) AS M_IN_QTY_OVR                                        
                                 , S012.LOT_BUF AS LOT_NO               --원자재코드
                                 , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                 , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                 , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
                                 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY        --잔량
                                 , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적수량
                                 , S012.UNIT                --단위
                                 , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                 , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                 , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                 , S012.ORDER_RMK           --오더비고
                                 , S012.SAL_RMK             --폐품비고
                                 , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                 , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                                 , W011.MACH_STA AS ORG_MACH_STA                                --원가동상태
                                 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_STR_DTM ELSE TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') END AS PRD_STR_DATE --시작시간
                                 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_END_DTM ELSE NULL END AS PRD_END_DATE --완료시간
                                 , W002.WRK_SEQ
                                 , '' AS DISPO_CD
                                 , '' AS DISPO_NM
                                 , NVL(S012.ROLL_QTY,0) AS ROLL_QTY
                                 , S012.DLFL AS DLFL 
                            FROM TB_WRK011 W011            --작업장 현황
                                 ,TB_LAMI_SL S012            --화장지 가공기 작업지시
                                 ,TB_MAS001 M001            --자재정보
                                 ,TB_MAS001 M002            --자재정보
                                 ,TB_WRK002 W002
                                 ,TB_MAS023 M023
                                -- ,TB_INV003 I003
                                 ,TB_SCH020 S020
                            WHERE 1=1 
                            AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                            AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                            AND W011.MACH_CD = P_MACH_CD
                            AND W011.IN_OUT = P_IOTYPE
                            AND W011.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                            AND S012.SALCODE = M023.DISPO_CD(+)
                            AND S012.WERKS = M023.WERKS(+)
                            --AND S012.WRK_ORDR_NO = I003.WRK_ORDR_NO
                           -- AND S012.WRK_ORDR_SEQNO = I003.WRK_ORDR_SEQNO
                          --  AND M002.MATNR = I003.MATNR
                            AND S012.WRK_ORDR_NO = S020.WRK_ORDR_NO
                            AND S012.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
                            AND M002.MATNR = S020.MATNR                            
                            ;                        
                        END;
                    ELSE
                        BEGIN
                            OPEN CUR_3 FOR
                            SELECT S012.PRD_REQ_DT         --생산지시일
                                 , S012.WRK_ORDR_NO         --작업지시
                                 , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.ORDER_NO            --생산오더
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , NVL(S020.MATNR,'') AS M_MATNR               --원자재코드
                                 , NVL(M002.MATNR_NM,'') AS M_MATNR_NM
                                 , NVL(S020.LOT_NO,'') AS M_LOT_NO               --원자재코드
                                 , NULL AS M_IND_BCD               --원자재코드
                                 , 0 AS M_IN_QTY
                                 , NVL(S020.ORDER_BOM_QTY,0) AS M_IN_QTY_OVR
                                 , S012.LOT_BUF AS LOT_NO               --원자재코드
                                 , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                 , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                 , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
                                 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY        --잔량
                                 , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적수량
                                 , S012.UNIT                --단위
                                 , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                 , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                 , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                 , S012.ORDER_RMK           --오더비고
                                 , S012.SAL_RMK             --폐품비고
                                 , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                 , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                                 , W011.MACH_STA AS ORG_MACH_STA                                --원가동상태
                                 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_STR_DTM ELSE TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') END AS PRD_STR_DATE --시작시간
                                 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_END_DTM ELSE NULL END AS PRD_END_DATE --완료시간
                                 , W002.WRK_SEQ
                                 , '' AS DISPO_CD
                                 , '' AS DISPO_NM
                                 , NVL(S012.ROLL_QTY,0) AS ROLL_QTY
                                 , S012.DLFL AS DLFL 
                            FROM TB_WRK011 W011            --작업장 현황
                                 ,TB_LAMI_SL S012            --화장지 가공기 작업지시
                                 ,TB_MAS001 M001            --자재정보
                                 ,TB_MAS001 M002            --자재정보
                                 ,TB_WRK002 W002
                                 ,TB_MAS023 M023
                                 ,TB_SCH020 S020
                            WHERE 1=1 
                            AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                            AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                            AND W011.MACH_CD = P_MACH_CD
                            AND W011.IN_OUT = P_IOTYPE
                            AND W011.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                            AND S012.SALCODE = M023.DISPO_CD(+)
                            AND S012.WERKS = M023.WERKS(+)
                            AND S012.WRK_ORDR_NO = S020.WRK_ORDR_NO
                            AND S012.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
                            AND M002.MATNR = S020.MATNR
                            ;                        
                        END;
                    END IF;

				END;
			ELSIF V_LAMI_SL_DVI > 0 AND V_LAMI_SL_RES > 0 AND V_LAMI_PC_DVI = 0 THEN
				BEGIN
                    IF V_MAT_INPUT_CNT > 0 THEN
                        BEGIN
                            OPEN CUR_3 FOR
                            SELECT A.PRD_REQ_DT         --생산지시일
                                  ,A.WRK_ORDR_NO         --작업지시
                                  , A.WRK_ORDR_SEQNO      --작업지시 순번
                                  , A.ORDER_NO            --생산오더
                                  , A.MATNR               --자재코드
                                  , A.MATNR_NM            --자재명
                                  , A.M_MATNR               --투입자재코드
                                  , A.M_MATNR_NM            --투입자재명
                                  , A.M_LOT_NO            --투입자재LOTNO
                                  , A.M_IND_BCD            --투입자재 바코드
                                  , A.M_IN_QTY
                                  , A.M_IN_QTY_OVR
                                  , A.LOT_NO            --LOTNO
                                  , A.BS_WGT              --평량
                                  , A.WLEN                --가로길이
                                  , A.WRK_ORDR_QTY        --계획수량
                                  , A.PRFM_QTY            --실적수량
                                  , A.UNIT                --단위
                                  , A.SALWEIGHT           --폐품처리량
                                  , A.PRFMMET_QTY       --실적미터
                                  , A.ORDER_RMK           --오더비고
                                  , A.SAL_RMK             --폐품비고
                                  , A.SALMETER           --폐품미터
                                  , A.WRK_ORDR_RMK   --작업지시사항
                                  , A.MACH_STA           --가동여부
                                  , A.ORG_MACH_STA
                                  , A.PRD_STR_DATE --시작시간
                                  , A.PRD_END_DATE --완료시간
                                  , A.WRK_SEQ
                                  , '' AS DISPO_CD
                                  , '' AS DISPO_NM
                                  , A.ROLL_QTY
                                  , A.REMAIN_QTY
                                  , A.DLFL 
                            FROM (
                                    SELECT S012.PRD_REQ_DT         --생산지시일
                                         , W011.WRK_ORDR_NO         --작업지시
                                         , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                         , S012.ORDER_NO            --생산오더
                                         , S012.MATNR               --자재코드
                                         , M001.MATNR_NM            --자재명
                                         , NVL(I003.MATNR,'') AS M_MATNR               --원자재코드
                                         , NVL(M002.MATNR_NM,'') AS M_MATNR_NM
                                         , NVL(I003.LOT_NO,'') AS M_LOT_NO               --원자재코드
                                         , NVL(I003.IND_BCD,'') AS M_IND_BCD               --원자재코드
                                         , NVL(I003.IN_QTY,0) AS M_IN_QTY
                                         , NVL(S020.ORDER_BOM_QTY,0) AS M_IN_QTY_OVR    -- 투입지시량
                                         , S012.LOT_BUF AS LOT_NO               --원자재코드
                                         , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                         , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                         , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
                                         , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적량
                                         , S012.UNIT AS UNIT               --단위
                                         , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                         , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                         , S012.ORDER_RMK           --오더비고
                                         , S012.SAL_RMK             --폐품비고
                                         , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                         , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                         , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                                         , W011.MACH_STA AS ORG_MACH_STA                                --원가동상태
                                         , CASE 
                                                WHEN DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') <> 'S' THEN
                                                    (SELECT MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS')) FROM TB_LAMI_SL_RESULT
                                                        WHERE WERKS = S012.WERKS 
                                                        AND MACH_CD = S012.MACH_CD 
                                                        AND WRK_ORDR_NO = S012.WRK_ORDR_NO 
                                                        AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO 
                                                        AND USE_YN = 'Y')
                                                ELSE
												S012.PRD_STR_DTM
                                            END AS PRD_STR_DATE                                           --시작시간            
                                         , S012.PRD_LAST_DATE AS PRD_END_DATE --완료시간
                                         , 0 WRK_SEQ
                                         , NVL(M023.DISPO_CD,'') AS DISPO_CD
                                         , NVL(M023.DISPO_NM,'') AS DISPO_NM
                                         , NVL(S012.ROLL_QTY,0) AS ROLL_QTY
                                         , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY            --실적량
                                         , S012.DLFL AS DLFL 
                                    FROM TB_WRK011 W011,            --작업장 현황
                                         TB_LAMI_SL S012,            --화장지 가공기 작업지시
                                         TB_MAS001 M001,            --자재정보
                                         TB_MAS001 M002            --자재정보
                                          ,TB_MAS023 M023
                                          ,TB_INV003 I003
                                          ,TB_SCH020 S020
                                    WHERE 1=1 
                                    AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                                    AND S012.WERKS = M001.WERKS(+)
                                    AND S012.MATNR = M001.MATNR(+)
                                    AND W011.MACH_CD = P_MACH_CD
                                    AND W011.IN_OUT = 'N'
                                    AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                                    AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                    AND S012.USE_YN = 'Y'
                                    AND S012.SALCODE = M023.DISPO_CD(+)
                                    AND S012.WERKS = M023.WERKS(+)
                                    AND S012.WRK_ORDR_NO = I003.WRK_ORDR_NO
                                    AND S012.WRK_ORDR_SEQNO = I003.WRK_ORDR_SEQNO
                                    AND M002.MATNR = I003.MATNR
                                    AND S012.WRK_ORDR_NO = S020.WRK_ORDR_NO
                                    AND S012.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO  
                                    AND M002.MATNR = S020.MATNR                                    
                                    ) A
                                    ;
                        END;
                    ELSE
                        BEGIN
                            OPEN CUR_3 FOR
                            SELECT A.PRD_REQ_DT         --생산지시일
                                  ,A.WRK_ORDR_NO         --작업지시
                                  , A.WRK_ORDR_SEQNO      --작업지시 순번
                                  , A.ORDER_NO            --생산오더
                                  , A.MATNR               --자재코드
                                  , A.MATNR_NM            --자재명
                                  , A.M_MATNR               --원자재코드
                                  , A.M_MATNR_NM            --원자재명
                                  , A.M_LOT_NO            --LOTNO
                                  , A.M_IND_BCD            --LOTNO
                                  , A.M_IN_QTY
                                  , A.M_IN_QTY_OVR
                                  , A.LOT_NO            --LOTNO
                                  , A.BS_WGT              --평량
                                  , A.WLEN                --가로길이
                                  , A.WRK_ORDR_QTY        --계획수량
                                  , A.PRFM_QTY            --실적수량
                                  , A.UNIT                --단위
                                  , A.SALWEIGHT           --폐품처리량
                                  , A.PRFMMET_QTY       --실적미터
                                  , A.ORDER_RMK           --오더비고
                                  , A.SAL_RMK             --폐품비고
                                  , A.SALMETER           --폐품미터
                                  , A.WRK_ORDR_RMK   --작업지시사항
                                  , A.MACH_STA           --가동여부
                                  , A.ORG_MACH_STA
                                  , A.PRD_STR_DATE --시작시간
                                  , A.PRD_END_DATE --완료시간
                                  , A.WRK_SEQ
                                  , '' AS DISPO_CD
                                  , '' AS DISPO_NM
                                  , A.ROLL_QTY
                                  , A.REMAIN_QTY
                                  , A.DLFL 
                            FROM (
                                    SELECT S012.PRD_REQ_DT         --생산지시일
                                         , W011.WRK_ORDR_NO         --작업지시
                                         , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                         , S012.ORDER_NO            --생산오더
                                         , S012.MATNR               --자재코드
                                         , M001.MATNR_NM            --자재명
                                         , NVL(S020.MATNR,'') AS M_MATNR               --원자재코드
                                         , NVL(M002.MATNR_NM,'') AS M_MATNR_NM
                                         , NVL(S020.LOT_NO,'') AS M_LOT_NO               --원자재코드
                                         , NULL AS M_IND_BCD               --원자재코드
                                         , 0 AS M_IN_QTY                                -- 투입량
                                         , NVL(S020.ORDER_BOM_QTY,0) AS M_IN_QTY_OVR    -- 투입지시량
                                         , S012.LOT_BUF AS LOT_NO               --원자재코드
                                         , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                         , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                         , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
                                         , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적량
                                         , S012.UNIT AS UNIT               --단위
                                         , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                         , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                         , S012.ORDER_RMK           --오더비고
                                         , S012.SAL_RMK             --폐품비고
                                         , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                         , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                         , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                                         , W011.MACH_STA AS ORG_MACH_STA                                --원가동상태
                                         , CASE 
                                                WHEN DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') <> 'S' THEN
                                                    (SELECT MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS')) FROM TB_LAMI_SL_RESULT
                                                        WHERE WERKS = S012.WERKS 
                                                        AND MACH_CD = S012.MACH_CD 
                                                        AND WRK_ORDR_NO = S012.WRK_ORDR_NO 
                                                        AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO 
                                                        AND USE_YN = 'Y')
                                                ELSE
												S012.PRD_STR_DTM
                                            END AS PRD_STR_DATE                                           --시작시간            
                                         , S012.PRD_END_DTM AS PRD_END_DATE --완료시간
                                         , 0 WRK_SEQ
                                         , NVL(M023.DISPO_CD,'') AS DISPO_CD
                                         , NVL(M023.DISPO_NM,'') AS DISPO_NM
                                         , NVL(S012.ROLL_QTY,0) AS ROLL_QTY
                                         , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY            --실적량
                                         , S012.DLFL AS DLFL 
                                    FROM TB_WRK011 W011,            --작업장 현황
                                         TB_LAMI_SL S012,            --화장지 가공기 작업지시
                                         TB_MAS001 M001            --자재정보
                                          ,TB_MAS001 M002
                                          ,TB_MAS023 M023
                                          ,TB_SCH020 S020
                                    WHERE 1=1 
                                    AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                                    AND S012.WERKS = M001.WERKS(+)
                                    AND S012.MATNR = M001.MATNR(+)
                                    AND W011.MACH_CD = P_MACH_CD
                                    AND W011.IN_OUT = 'N'
                                    AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                                    AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                    AND S012.USE_YN = 'Y'
                                    AND S012.SALCODE = M023.DISPO_CD(+)
                                    AND S012.WERKS = M023.WERKS(+)
                                    AND S012.WRK_ORDR_NO = S020.WRK_ORDR_NO
                                    AND S012.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO
                                    AND M002.MATNR = S020.MATNR
                                    ) A
                                    ;
                        END;
                    END IF;
				END;
			ELSIF V_LAMI_SL_DVI = 0 AND V_LAMI_SL_RES = 0 THEN
				BEGIN

					OPEN CUR_3 FOR
                    SELECT A.PRD_REQ_DT         --생산지시일
                          ,A.WRK_ORDR_NO         --작업지시
                          , A.WRK_ORDR_SEQNO      --작업지시 순번
                          , A.ORDER_NO            --생산오더
                          , A.MATNR               --자재코드
                          , A.MATNR_NM            --자재명
                          , A.BS_WGT              --평량
                          , A.WLEN                --가로길이
                          , A.WRK_ORDR_QTY        --계획수량
                          , A.PRFM_QTY            --실적수량
                          , A.UNIT                --단위
                          , A.SALWEIGHT           --폐품처리량
                          , A.PRFMMET_QTY       --실적미터
                          , A.ORDER_RMK           --오더비고
                          , A.SAL_RMK             --폐품비고
                          , A.SALMETER           --폐품미터
                          , A.WRK_ORDR_RMK   --작업지시사항
                          , A.MACH_STA           --가동여부
                          , A.ORG_MACH_STA
                          , A.PRD_STR_DATE --시작시간
                          , A.PRD_END_DATE --완료시간
                          , A.WRK_SEQ
                          , '' AS DISPO_CD
                          , '' AS DISPO_NM
                          , A.ROLL_QTY
                          , A.REMAIN_QTY
                          , A.DLFL
                    FROM (
                            SELECT S012.PRD_REQ_DT         --생산지시일
                                 , W011.WRK_ORDR_NO         --작업지시
                                 , S012.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO      --작업지시 순번
                                 , S012.ORDER_NO            --생산오더
                                 , S012.MATNR               --자재코드
                                 , M001.MATNR_NM            --자재명
                                 , NVL(M001.BS_WGT,0) AS BS_WGT              --평량
                                 , NVL(M001.WLEN,0) AS WLEN                --가로길이
                                 , NVL(S012.WRK_ORDR_QTY,0) AS WRK_ORDR_QTY        --계획수량
                                 , NVL(S012.PRFM_QTY,0) AS PRFM_QTY            --실적량
                                 , S012.UNIT AS UNIT               --단위
                                 , NVL(S012.SALWEIGHT,0) AS SALWEIGHT           --폐품처리량
                                 , NVL(S012.PRFMMET_QTY,0) AS PRFMMET_QTY       --실적미터
                                 , S012.ORDER_RMK           --오더비고
                                 , S012.SAL_RMK             --폐품비고
                                 , NVL(S012.SALMETER,0) AS SALMETER           --폐품미터
                                 , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
                                 , DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') AS MACH_STA           --가동여부
                                 , W011.MACH_STA AS ORG_MACH_STA                                --원가동상태
                                 , CASE 
                                        WHEN DECODE(V_ABN_STA,0, W011.MACH_STA, 'S') <> 'S' AND S012.DLFL != 'A' THEN
                                            (SELECT MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS')) FROM TB_LAMI_SL_RESULT
                                                WHERE WERKS = S012.WERKS 
                                                AND MACH_CD = S012.MACH_CD 
                                                AND WRK_ORDR_NO = S012.WRK_ORDR_NO 
                                                AND WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO 
                                                AND USE_YN = 'Y')
                                        ELSE
                                           CASE WHEN S012.DLFL = 'A' THEN S012.PRD_STR_DTM ELSE TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') END
                                    END AS PRD_STR_DATE                                           --시작시간            
                                 , CASE WHEN S012.DLFL = 'A' THEN S012.PRD_END_DTM ELSE NULL END AS PRD_END_DATE --완료시간
                                 , 0 WRK_SEQ
                                 , NVL(M023.DISPO_CD,'') AS DISPO_CD
                                 , NVL(M023.DISPO_NM,'') AS DISPO_NM
                                 , NVL(S012.ROLL_QTY,0) AS ROLL_QTY
                                 , NVL(S012.REMAIN_QTY,0) AS REMAIN_QTY            --실적량
                                 , S012.DLFL AS DLFL 
                            FROM TB_WRK011 W011,            --작업장 현황
                                 TB_LAMI_SL S012,            --화장지 가공기 작업지시
                                 TB_MAS001 M001            --자재정보
                                ,TB_MAS023 M023
                            WHERE 1=1 
                            AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
                            AND S012.WERKS = M001.WERKS(+)
                            AND S012.MATNR = M001.MATNR(+)
                            AND W011.MACH_CD = P_MACH_CD
                            AND W011.IN_OUT = 'N'
                            AND S012.WRK_ORDR_NO = V_WRK_ORDR_NO
                            AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                            AND S012.USE_YN = 'Y'
                            AND S012.SALCODE = M023.DISPO_CD(+)
                            AND S012.WERKS = M023.WERKS(+)
                            ) A
                            ;
				END;
			END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;

        --투입 grid 컬럼 정보 설정
        --grid1 컬럼 정보 설정
        V_COLINFO1 := '선택@C^60|바코드@C^200|투입량@C^160|자재코드@H|작업지시번호@H|작업지시순번@H|LOT_NO@H';
        V_COLTYPE1 := 'CHK@Button|IND_BCD@varchar|IN_QTY@varchar|MATNR@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|LOT_NO@varchar';        --컬럼설정 반환 테이블 작성
        OPEN CUR_4 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1||','||V_COLTYPE1,',');

        BEGIN
        OPEN CUR_5 FOR
            SELECT
                '-' CHK
                ,A.IND_BCD
                ,NVL(TO_CHAR(A.IN_QTY, 'fm999,999,999,999'), '0')  IN_QTY 
                ,A.MATNR     
                ,A.WRK_ORDR_NO
                ,A.WRK_ORDR_SEQNO
                ,A.LOT_NO
            FROM TB_INV003 A
                INNER JOIN TB_LAMI_SL B
                    ON A.WERKS = B.WERKS
                    AND A.WRK_ORDR_NO = B.WRK_ORDR_NO
                    AND A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO
                    AND NVL(B.COMP_YN,'N') <> 'Y' 
            WHERE A.WRK_ORDR_NO = V_WRK_ORDR_NO
            AND A.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
            AND A.STCK_QTY > 0
            ORDER BY A.IND_BCD;
        END;
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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END ;
/
