--------------------------------------------------------
--  DDL for Procedure SP_WRK23_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK23_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK23_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : LOT 추적 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재공조회(호기 및 각 공정별 재공재고 정보 조회) {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/31 {최초 작성일자 기술}
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
 *  관련 테이블 - 모든 테이블 조회만 함
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK23_S01';     -- PROCEDURE NAME


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
    V_WERKS			TB_WRK008.WERKS%TYPE;			-- 플랜트
    V_IND_BCD		TB_WRK008.IND_BCD%TYPE;			-- 개별바코드
    V_LOT_NO		TB_WRK008.LOT_NO%TYPE;			-- LOT_NO

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
--    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS			 	 := 		V_JSON.get_string('WERKS');		-- 플랜트  
    V_IND_BCD			 := 		V_JSON.get_string('IND_BCD');	-- 개별바코드
    V_LOT_NO			 := 		V_JSON.get_string('LOT_NO');	-- 개별바코드



    IF P_TYPE = 'LIST' THEN /*좌측 메인 그리드*/

        V_SQL :=  ' WITH PRM AS (
						SELECT ' ;
		V_SQL := V_SQL || '''' || V_IND_BCD || '''';

		V_SQL := V_SQL || ' IND_BCD FROM DUAL )';


--        V_SQL :=  ' WITH PRM AS (
--						SELECT ''H20220701H40006'' IND_BCD
--						  FROM DUAL
--					) ' ;


        V_SQL :=  V_SQL || ' SELECT
							       MAS013.PROC_NM
		                         , MAS001.MATNR_NM
							     , MAS012.MACH_NM
							     , MAS001_INPT.MATNR_NM AS MATNR_NM_M
							     , MAS012_INPT.MACH_NM AS MACH_NM_M
							     , BASE.USE_QTY AS IN_QTY
                                 , MAS013.DISP_SEQ
							     , BASE.*
							  FROM (
								SELECT * FROM (
								   SELECT * FROM TB_WRK008 WRK008   --LOT 추적
									--WHERE WERKS = (SELECT WERKS FROM PRM)
									START WITH IND_BCD = (SELECT IND_BCD FROM PRM)
									CONNECT BY PRIOR IND_BCD_M = IND_BCD
									ORDER BY LOT_NO DESC
								)
								UNION
								SELECT * FROM (
								   SELECT * FROM TB_WRK008   --LOT 추적
									--WHERE WERKS = (SELECT WERKS FROM PRM)
									START WITH IND_BCD_M = (SELECT IND_BCD FROM PRM)
									CONNECT BY PRIOR IND_BCD = IND_BCD_M
									ORDER BY LOT_NO
								)
							) BASE
							LEFT JOIN TB_MAS001 MAS001 --자재마스터
							  ON MAS001.MATNR = BASE.MATNR
							 AND MAS001.WERKS = BASE.WERKS
							LEFT JOIN TB_MAS012 MAS012 --설비마스터
							  ON MAS012.MACH_CD = BASE.MACH_CD
							LEFT JOIN TB_MAS013 MAS013  --공정마스터
							  ON MAS013.PROC_CD = MAS012.PROC_CD
							LEFT JOIN TB_MAS001 MAS001_INPT --자재마스터
							  ON MAS001_INPT.MATNR = BASE.MATNR_M
							 AND MAS001_INPT.WERKS = BASE.WERKS
							LEFT JOIN TB_MAS012 MAS012_INPT --설비마스터
							  ON MAS012_INPT.MACH_CD = BASE.MACH_CD
		                    WHERE 1=1 ';


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ' AND BASE.WERKS = ''' || V_WERKS || '''';        
        END IF;

--        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--            V_SQL := V_SQL || V_RANGE_SQL;
--        END IF;

         V_SQL := V_SQL || ' ORDER BY MAS013.DISP_SEQ';


--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


		OPEN P_RS_LIST FOR V_SQL;





	ELSIF P_TYPE = 'SUB_LIST1' THEN   --오더/지시


        V_SQL :=  ' WITH PRM AS (
						SELECT ' ;
		V_SQL := V_SQL || '''' || V_LOT_NO || '''';

		V_SQL := V_SQL || ' LOT_NO FROM DUAL )';

        V_SQL :=  V_SQL || ' , BASE_TB AS (
						SELECT DISTINCT MAS012.MACH_NM
						     , MAS001.MATNR_NM
						     , B.*
						  FROM (
						    SELECT A.WRK_ORDR_NO
							     , A.WRK_ORDR_SEQNO
							     , A.WERKS
							     , A.ORDER_NO
							     --생산요청 컬럼 물어서 적용
							     , A.MACH_CD
							     , A.MATNR
							  FROM TB_WRK001 A --실적(HL)
							  JOIN PRM PRM
							    ON PRM.LOT_NO = A.LOT_NO
					--		    ON PRM.WERKS = A.WERKS
					--		   AND PRM.MACH_CD = A.MACH_CD
					--		   AND PRM.IND_BCD = A.IND_BCD
							UNION ALL
							SELECT A.WRK_ORDR_NO
							     , A.WRK_ORDR_SEQNO
							     , A.WERKS
							     , A.ORDER_NO
							     --생산요청 컬럼 물어서 적용
							     , A.MACH_CD
							     , A.MATNR
							  FROM TB_WRK002 A --실적(PS)
							  JOIN PRM PRM
							    ON PRM.LOT_NO = A.LOT_NO
					--		    ON PRM.WERKS = A.WERKS
					--		   AND PRM.MACH_CD = A.MACH_CD
					--		   AND PRM.IND_BCD = A.IND_BCD
						  ) B
						  LEFT JOIN TB_MAS001 MAS001 --자재마스터
						    ON MAS001.MATNR = B.MATNR
						   AND MAS001.WERKS = B.WERKS
						  LEFT JOIN TB_MAS012 MAS012 --설비마스터
						    ON MAS012.MACH_CD = B.MACH_CD
					)
					--SELECT * FROM BASE_TB;
					, LVL_A AS (
						SELECT * FROM (
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, A.ORDER_QTY, A.ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH011 A --작업지시 화장지초지
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, A.ORDER_QTY, A.ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH012 A --작업지시 화장지가공
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, A.ORDER_QTY, A.ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH013 A --작업지시 패드
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, A.ORDER_QTY, A.ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH014 A --작업지시 기저귀
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, 0 ORDER_QTY, '''' ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH015 A --작업지시 점보롤
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, 0 ORDER_QTY, '''' ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH016 A --작업지시 밀롤,슬리터	
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, 0 ORDER_QTY, '''' ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH017 A --작업지시 재단
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, 0 ORDER_QTY, '''' ORDER_DIV, A.ORDER_RMK, A.WRK_SEQNO, A.WRK_ORDR_RMK
							  FROM TB_SCH018 A --작업지시 포장
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
							UNION ALL
							SELECT BASE.MACH_NM, BASE.MATNR, BASE.MATNR_NM, BASE.WRK_ORDR_NO
							     , A.ORDER_NO, A.UNIT, 0 ORDER_QTY, '''' ORDER_DIV, '''' ORDER_RMK, A.WRK_SEQNO, '''' WRK_ORDR_RMK
							  FROM TB_SCH019 A --작업지시 예외생산
							  JOIN BASE_TB BASE
							    ON BASE.WRK_ORDR_NO = A.WRK_ORDR_NO
							   AND BASE.WRK_ORDR_SEQNO = A.WRK_ORDR_SEQNO
						)
					)
					--SELECT * FROM LVL_A;
					, LVL_B AS (
						SELECT * FROM (
							SELECT Z.SEQ, Z.FQTY, Z.REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A
							  JOIN TB_SCH002 Z  --생산-오더 화장지초지
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT Z.SEQ, Z.FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A
							  JOIN TB_SCH003 Z  --생산-오더 화장지가공
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT Z.SEQ, Z.FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A
							  JOIN TB_SCH004 Z  --생산-오더 패드
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT Z.SEQ, Z.FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A
							  JOIN TB_SCH005 Z  --생산-오더 기저귀
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT '''' SEQ, 0 FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A 
							  JOIN TB_SCH006 Z  --생산-오더 점보롤
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT '''' SEQ, 0 FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A 
							  JOIN TB_SCH007 Z  --생산-오더 밀롤,슬리터	
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT '''' SEQ, 0 FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A 
							  JOIN TB_SCH008 Z  --생산-오더 재단
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT '''' SEQ, 0 FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A 
							  JOIN TB_SCH009 Z  --생산-오더 포장
							    ON Z.AUFNR = LVL_A.ORDER_NO
							UNION ALL
							SELECT '''' SEQ, 0 FQTY, '''' REMRK
							     , LVL_A.*
							  FROM LVL_A LVL_A 
							  JOIN TB_SCH010 Z  --생산-오더 예외생산
							    ON Z.AUFNR = LVL_A.ORDER_NO
						)
					)
					--SELECT * FROM LVL_B;
					SELECT ORDER_NO
					     --생산요청 컬럼 물어서 적용
					     , MACH_NM
						 , MATNR
						 , MATNR_NM
						 , UNIT
						 , ORDER_QTY
						 , ORDER_DIV
						 , ORDER_RMK AS RMK
						 , WRK_ORDR_NO
						 , NVL(SEQ, WRK_SEQNO) WRK_SEQNO   --JOB_SEQ_NO
						 , FQTY
						 , NVL(REMRK, WRK_ORDR_RMK) WRK_ORDR_REMARK   --WRK_ORDR_RMK   --JOB_ORDR_RMK
					  FROM LVL_B ';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'SUB_LIST2' THEN   --자재입고현황


        V_SQL :=  ' SELECT DISTINCT
					       INV007.MATNR                  --자재코드
					     , MAS001.MATNR_NM               --자재명
					     , INV007.PRDC_DT                --제조일자
		 			     , '''' AS SUPY        --공급업체(WMS로 부터 받지 않음)
					     , INV007.LOT_NO AS VND_LOT_NO   --업체 LOT번호
					     , INV007.IND_BCD AS BARCODE_NO  --업체 개별바코드
					     , INV007.UNIT                   --단위
					     , INV007.QTY                    --수량
					     , INV007.RCVCDS_DT AS RCVGDS_DT --입고일자
					     , INV007.DSTBT_DDLIN            --유통기한
					  FROM TB_WRK008 WRK008
					  LEFT JOIN TB_INV001 INV001
					    ON INV001.WERKS = WRK008.WERKS
					   AND INV001.IND_BCD = WRK008.IND_BCD_M
					   AND INV001.MATNR = WRK008.MATNR_M
					  LEFT JOIN TB_INV007 INV007
					   ON INV007.WERKS = INV001.WERKS
					   AND INV007.MATNR = INV001.MATNR
                       AND INV007.IND_BCD = INV001.IND_BCD
                       AND INV007.DLFL  <> ''D''
                       AND INV007.REQ_DIV IN (''10'',''40'')
					  LEFT JOIN TB_MAS001 MAS001 --자재마스터
					    ON MAS001.MATNR = INV007.MATNR
					   AND MAS001.WERKS = INV007.WERKS
					 WHERE 1=1
					   AND (INV007.MATNR IS NOT NULL
					        OR MAS001.MATNR_NM IS NOT NULL
					        OR INV007.PRDC_DT IS NOT NULL
					        OR INV007.LOT_NO IS NOT NULL
					        OR INV007.IND_BCD IS NOT NULL
					        OR INV007.UNIT IS NOT NULL
					        OR INV007.QTY IS NOT NULL
					        OR INV007.RCVCDS_DT IS NOT NULL
					        OR INV007.DSTBT_DDLIN IS NOT NULL
					   ) ';


--		IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
--            V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''';        
--        END IF;

        V_SQL := V_SQL || ' AND WRK008.LOT_NO = ''' || V_LOT_NO || '''';

		--V_SQL := V_SQL || '''' || V_LOT_NO || '''';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'SUB_LIST3' THEN   --투입현황


        V_SQL :=  ' SELECT 
					       INV010.INP_DT     --투입일자
					     , M012.MACH_NM      --설비명
					     , INV010.LOT_NO    --LOT_NO
					     , INV010.IND_BCD    --개별 바코드
					     , INV010.SEQNO   AS INPT_SEQNO -- 투입순서					
					     , INV010.MATNR      --자재코드
					     , M001.MATNR_NM     --자재명
					     , INV010.UNIT       --단위
					     , INV010.USE_QTY AS INP_QTY      --투입량
					     , INV010.IND_BCD_M AS IND_BCD_M2 --투입자재 업체/개별 바코드
					     , INV010.LOT_NO_M AS LOT_NO_M2   --투입자재 LOT NO
					     , INV010.MATNR_M AS MATNR_M2     --투입자재 자재코드
					     , INV010.CHG_FLG    --대체여부
					     , INV010.REGDATE AS STR_DATE     --투입일시					
					  FROM TB_INV010 INV010     --자재투입
					  LEFT JOIN TB_MAS012 M012  --설비 마스터
					    ON M012.MACH_CD = INV010.MACH_CD
					  LEFT JOIN TB_MAS001 M001  --자재
					    ON M001.WERKS = INV010.WERKS
					   AND M001.MATNR = INV010.MATNR
					 WHERE 1=1 AND INV010.LOT_NO = ';


		V_SQL := V_SQL || '''' || V_LOT_NO || '''';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'SUB_LIST4' THEN   --실적현황


        V_SQL :=  ' WITH PRM AS (
						SELECT ' ;
		V_SQL := V_SQL || '''' || V_LOT_NO || '''';

		V_SQL := V_SQL || ' LOT_NO FROM DUAL )';

        V_SQL :=  V_SQL || ' SELECT
							       MAS013.PROC_NM                       AS PROC_NM        --공정명
							     , MAS012.MACH_NM       				AS MACH_NM        --설비명
							     , MAS001.MATNR_NM       			    AS MATNR_NM       --자재명
							     , COALESCE(MAS017.EMPLY_KR_NM, USR.NMLAST, USR.USER_NM, BASE.REGID) AS WRKNM  --작업자
							     , BASE.*
							  FROM (
								SELECT WRK001.WERKS                         AS WERKS          --플랜트
								     , WRK001.MACH_CD                       AS MACH_CD        --설비코드
								     , WRK001.PRFM_DT                       AS PRFM_DT        --실적일자
								     , ''''                     			AS MACHINE        --생산호기
								     , WRK001.LOT_NO       			        AS LOT_NO         --LOT번호
								     , WRK001.IND_BCD       			    AS IND_BCD        --개별바코드
								     , WRK001.MATNR       			        AS MATNR          --자재코드
								     , WRK001.UNIT       			        AS UNIT           --단위
								--     , WRK001.WGT       			        AS WGT            --실적중량
								     , WRK001.PLT_QTY       			    AS PLT_QTY        --PLT
								     , WRK001.BOX_QTY       			    AS BOX_QTY        --BOX
								     , WRK001.BAG_QTY       			    AS BAG_QTY        --BAG
								     , WRK001.EA_QTY       			        AS EA_QTY         --EA
								     , WRK001.WGT       			        AS WGT            --실적중량
								     , 0                                    AS VLEN           --세로길이
								     , 0                                    AS WLEN           --가로길이
								     , WRK001.PRD_STR_DATE       			AS PRD_STR_DATE   --시작시간
								     , WRK001.PRD_END_DATE       			AS PRD_END_DATE   --종료시간
								     , WRK001.REGID
								     , WRK001.WRK_CLASS       			    AS WRK_CLASS      --반
								     , WRK001.WRK_SHIFT       			    AS WRK_SHIFT      --작업조
								  FROM TB_WRK001 WRK001  --실적테이블(HL)
								  JOIN PRM PRM ON 1=1
								 WHERE 1=1
								   AND WRK001.LOT_NO = PRM.LOT_NO
							--	   AND WRK001.WERKS = PRM.WERKS
							--	   AND WRK001.MACH_CD = PRM.MACH_CD
							--	   AND WRK001.IND_BCD = PRM.IND_BCD
								UNION ALL
								SELECT WRK002.WERKS                         AS WERKS          --플랜트
								     , WRK002.MACH_CD                       AS MACH_CD        --설비코드
								     , WRK002.PRFM_DT                       AS PRFM_DT        --실적일자
								     , WRK002.MACHINE       			    AS MACHINE        --생산호기
								     , WRK002.LOT_NO       			        AS LOT_NO         --LOT번호
								     , WRK002.IND_BCD       			    AS IND_BCD        --개별바코드
								     , WRK002.MATNR       			        AS MATNR          --자재코드
								     , WRK002.UNIT       			        AS UNIT           --단위
								--     , WRK002.WGT       			        AS WGT            --실적중량
								     , 0       			                    AS PLT_QTY        --PLT
								     , 0       			                    AS BOX_QTY        --BOX
								     , 0       			                    AS BAG_QTY        --BAG
								     , 0      			                    AS EA_QTY         --EA
								     , WRK002.WGT       			        AS WGT            --실적중량
								     , WRK002.VLEN                          AS VLEN           --세로길이
								     , WRK002.WLEN                          AS WLEN           --가로길이
								     , WRK002.PRD_STR_DATE       			AS PRD_STR_DATE   --시작시간
								     , WRK002.PRD_END_DATE       			AS PRD_END_DATE   --종료시간
								     , WRK002.REGID
								     , WRK002.WRK_CLASS       			    AS WRK_CLASS      --반
								     , WRK002.WRK_SHIFT       			    AS WRK_SHIFT      --작업조
								  FROM TB_WRK002 WRK002  --실적테이블(PS)
								  JOIN PRM PRM ON 1=1
								 WHERE 1=1
								   AND WRK002.LOT_NO = PRM.LOT_NO
							--	   AND WRK002.WERKS = PRM.WERKS
							--	   AND WRK002.MACH_CD = PRM.MACH_CD
							--	   AND WRK002.IND_BCD = PRM.IND_BCD
							  ) BASE
							  LEFT JOIN TB_MAS012 MAS012  --설비코드
							    ON MAS012.MACH_CD = BASE.MACH_CD
							  LEFT JOIN TB_MAS013 MAS013  --공정마스터
							    ON MAS013.PROC_CD = MAS012.PROC_CD
							  LEFT JOIN TB_MAS001 MAS001 --자재마스터
							    ON MAS001.MATNR = BASE.MATNR
							   AND MAS001.WERKS = BASE.WERKS
							  LEFT JOIN USRMA USR --[WMS] [SYSTEM] 사용자
							    ON USR.USERID = BASE.REGID
							  LEFT JOIN TB_MAS017 MAS017 --직원 정보
							    ON MAS017.EMPLY_NO = USR.EMPLID ';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'SUB_LIST5' THEN   --품질현황(부적합)


        V_SQL :=  ' SELECT
					       QLT020.MSRM_DATE AS INSP_DATE
					     , FN_CD_VAL(''INSPCAT'', QLT020.INSP_ITEM_GRP_CD) AS INSP_TYPE
					     , QLT020.MATNR
					     , MAS001.MATNR_NM
					     , QLT020.LOT_NO
					     , QLT020.IND_BCD 
					     , M001.UNIT
					     , QLT020.FNL_JDGM 
					     , QLT020.UCFMTY_AMT 
					     , DECODE(QLT020.PRC_DIV, ''I'',''개별'', ''M'',''다중'') PRC_MTD
					     , QLT024.RMK  
					  FROM TB_QLT020 QLT020  --검사항목별 측정결과 마스터
					  LEFT JOIN TB_MAS001 MAS001 --자재마스터
					    ON MAS001.MATNR = QLT020.MATNR
					   AND MAS001.WERKS = QLT020.WERKS
					  LEFT JOIN TB_QLT024 QLT024  --부적합 처리 정보
					    ON QLT024.MSRM_DATE = QLT020.MSRM_DATE
					   AND QLT024.PRC_SEQNO = QLT020.PRC_SEQNO
					  LEFT JOIN TB_MAS001 M001  --자재기준정보
					    ON M001.MATNR = QLT020.MATNR
					   AND M001.WERKS = QLT020.WERKS
					 WHERE 1=1 AND QLT020.LOT_NO = ';


		V_SQL := V_SQL || '''' || V_LOT_NO || '''';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'SUB_LIST6' THEN   --완제품 입고현황(WMS)


        V_SQL :=  ' SELECT 
					       WRK015.RCVGDS_DT  --입고일자
					     , WRK015.IND_BCD
					     , WRK015.MATNR
					     , MAS001.MATNR_NM 
					     , WRK015.UNIT 
                         , WRK015.QTY
					     , WRK015.PLT_QTY 
					     , WRK015.BOX_QTY 
					     , WRK015.BAG_QTY 
					     , WRK015.EA_QTY  
					     , WRK015.WGT     
					     --, WRK015.PCODE  
					     , FN_CD_VAL(''PCODE'', WRK015.PCODE) PCODE_NM
					     , WRK015.BS_WGT       
					     , WRK015.WLEN         
					     , WRK015.VLEN         
					     , WRK015.CON_TYPE     
					     , WRK015.PACKTYPE     
					     , WRK015.EMPLY_NM     
					     , DECODE(WRK015.REQ_STA, ''R'',''요청'', ''O'',''출고'') REQ_STA
					  FROM TB_WRK015 WRK015  --완제품 출고 정보
					  LEFT JOIN TB_INV001 INV001  --공정재고
					    ON INV001.WERKS = WRK015.WERKS
					--   AND INV001.STOR_LOC_CD = WRK015.STOR_LOC_TO
					   AND INV001.IND_BCD = WRK015.IND_BCD
					   AND INV001.MATNR = WRK015.MATNR
					   AND INV001.LOT_NO = WRK015.LOT_NO
					  LEFT JOIN TB_MAS001 MAS001 --자재마스터
					    ON MAS001.MATNR = WRK015.MATNR
					   AND MAS001.WERKS = WRK015.WERKS
					--  LEFT JOIN TB_MAS001 M001  --자재기준정보
					--    ON M001.MATNR = WRK015.MATNR
					--   AND M001.WERKS = WRK015.WERKS
					 WHERE 1=1 AND WRK015.LOT_NO = ';


		V_SQL := V_SQL || '''' || V_LOT_NO || '''';


--		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;









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
