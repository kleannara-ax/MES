--------------------------------------------------------
--  DDL for Procedure SP_WRK27_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK27_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK27_S01
 * PROGRAM NAME  : 재단작업 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장작업 현황를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/06/08
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/08    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 뷰(가상 테이블)
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK27_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1) := 'Y';

	-- 조건절 처리용 변수선언 영역
    V_SDATE             varchar2(20);			--생산시작일자
    V_EDATE             varchar2(20);			--생산종료일자
    V_CNL_YN            TB_WRK002.CNL_YN%TYPE;          --취소여부
    V_PCODE             TB_SCH017.PCODE%TYPE;			--지종
    V_BS_WGT	        TB_SCH017.BS_WGT%TYPE;          --평량
    V_WLEN	            TB_SCH017.WLEN%TYPE;            --가로길
    V_VLEN	            TB_SCH017.VLEN%TYPE;            --세로길
    V_PRFM_DT			TB_WRK002.PRFM_DT%TYPE;		--실적일자

    V_MATNR             varchar2(20);
    V_MACH_CD           varchar2(20);  


	V_SQL				CLOB;

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

    --V_SDATE             := V_JSON.get_string('SDATE');			--생산시작일자
    --V_EDATE             := V_JSON.get_string('EDATE');			--생산종료일자
	V_PRFM_DT			:= V_JSON.get_string('PRFM_DT');		--실적일자
    V_PCODE             := V_JSON.get_string('PCODE');			--지종
    V_BS_WGT	        := V_JSON.get_string('BS_WGT');         --평량
    V_CNL_YN            := V_JSON.get_string('CNL_YN');         --취소여부
    --V_WLEN	            := V_JSON.get_string('WLEN');           --가로길
    --V_VLEN	            := V_JSON.get_string('VLEN');           --세로길

    --V_MATNR             varchar2(20);
    --V_MACH_CD           varchar2(20);  
    V_MATNR	        := V_JSON.get_string('MATNR');   
    V_MACH_CD	    := V_JSON.get_string('MACH_CD');
    


	IF P_TYPE = 'LIST' THEN
		V_SQL := 
		' SELECT    DISTINCT
                    B.PCODE                                                 PCODE       --지종코드
				  , C.PCODE_NM												PCODE_NM    --지종명
                  , B.BS_WGT                                                BS_WGT      --평량
                  , B.WLEN                                                  WLEN        --가로길
                  , B.VLEN                                                  VLEN        --세로길
                  , A.MATNR	                                                MATNR       --자재코드
                  , C.MATNR_NM                                              MATNR_NM    --자재명
                  , FN_CMCDV (''PACK_TYPE'', B.PACKTYPE)                                         PACKTYPE    --포장타입
                  , CASE WHEN C.DOMESTIC  = ''Y''  THEN ''내수''
                         WHEN C.DOMESTIC  = ''N''  THEN ''수출''
                         ELSE                         NULL
                     END  	                                                DOMESTIC    --내수구분
                  , H.CUST_NM                                               CUST_NM     --거래처명
                  , FN_CMCDV (''NTN_CD'', H.LAND1)                          NTN_NM      --국가명
                    , F.LOT_NO	                                            MLOT_NO     --밀롤LOTNO        
                    , F.IND_BCD	                                            MIND_BCD    --밀롤바코드
                    , F.PRD_DT                                              MPRD_DT     --밀롤생산일자
                    , G.MACH_NM                                             MACH_NM     --밀롤생산설비명
                    , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = F.REGID),F.REGID)  
                                                                            MREGNM	    --밀롤작업자
                    , F.ROLLCNT                                             MROLLCNT    --밀롤권치수
					, MRI.UNIT												MRUNIT		--밀롤단위
                    , B.PLT_PER_CNT                                         PLT_PER_CNT --팔레트당연수
                    , I.LOC_CD                                              LOC_CD      --로케이션
                   , A.PRD_DT 	                                            PRD_DT      --생산일자
                   , A.PRD_STR_DATE	                                        PRD_STR_DT  --생산시작일
                   , A.PRD_END_DATE                     	                PRD_END_DT  --생산종료일
                   , E.MACH_NM                                              CMACH_NM	--재단설비명
                   , A.WRK_CLASS	                                        WRK_CLASS   --반
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = A.REGID),A.REGID)                       
                                                                            CREGNM	    --재단작업자
                   , A.LOT_NO	                                            CLOT_NO     --재단LOTNO
                   , A.IND_BCD	                                            CIND_BCD    --재단바코드
				   , A.UNIT													CUNIT		--재단실적단위
				   , A.PRFM_QTY												CPRFM_QTY	--재단실적
                   , A.PCNT	                                                CPCNT       --재단실적연수
                   , A.WGT	                                                CWGT        --재단사용중량
                   , A.TM	                                                TM          --가동시간
                   , B.IN_PER_CNT                                           IN_PER_CNT  --속당매수
                   , NVL(A.CNL_YN, ''N'')                                   CNL_YN      --취소여부
                   , (
                        SELECT  MAX(Z1.DISPO_NM)
                         FROM TB_WRK004 Z, TB_MAS023 Z1
                        WHERE A.WRK_ORDR_NO =  Z.WRK_ORDR_NO
                          AND A.WRK_ORDR_SEQNO =  Z.WRK_ORDR_SEQNO
                          AND A.WERKS   =  Z.WERKS
                          AND Z.WERKS   =  Z1.WERKS
                          AND Z.DISPO_CD = Z1.DISPO_CD
                          AND NVL(Z.CNL_YN,''N'')  = ''N''                       
                      ) DISPO_CD
                   , ( SELECT  SUM(Z.DISPO_QTY/500)
                         FROM TB_WRK004 Z
                        WHERE A.WRK_ORDR_NO =  Z.WRK_ORDR_NO
                          AND A.WRK_ORDR_SEQNO =  Z.WRK_ORDR_SEQNO
                          AND A.WERKS   =  Z.WERKS
                          AND NVL(Z.CNL_YN,''N'')  = ''N'' 
                      ) DISPO_PCNT
                   , (
                        SELECT  SUM(Z.WGT)
                         FROM TB_WRK004 Z
                        WHERE A.WRK_ORDR_NO =  Z.WRK_ORDR_NO
                          AND A.WRK_ORDR_SEQNO =  Z.WRK_ORDR_SEQNO
                          AND A.WERKS   =  Z.WERKS
                          AND NVL(Z.CNL_YN,''N'')  = ''N''                    
                     ) DISPO_WGT                   
                    , A.RMK                               RMK                   --비고
                    , A.VBELN                                VBELN              --판매문서번호
                    , A.POSNR                                POSNR              --판매문서번호순번
                    , A.SDOC_NO                              SDOC_NO            --SAP확정문서번호
                    , A.SDOC_SEQNO                           SDOC_SEQNO         --SAP확정문서번호순번
                    ,B.COMP_YN            		            CUT_COMP_YN         --재단 완료여부
                    ,J.COMP_YN                         MIL_COMP_YN         -- 밀롤 완료여부
                    ,A.PRFM_DT                                PRFM_DT                 --실적일자
                    
              FROM TB_WRK002 A    --재단실적테이블(PS)
                 , TB_SCH017 B    --작업지시 재단
                 , TB_MAS001 C    --플랜트별 제품/자재 마스터
                 , TB_MAS012 D    --재단커터설비 마스터
                 , TB_MAS012 E    --재단설비 마스터
                 , TB_INV010 F1   --투입실적테이블(PS)
                 , TB_WRK002 F    --밀롤실적테이블(PS)
                 , TB_MAS012 G    --밀롤설비 마스터
                 , TB_MAS009 H    --거래처(고객사/공급사) 마스터
                 , TB_INV001 I    --재고
                 , TB_SCH016 J      --작업지시 밀롤
				 , TB_INV001 MRI	--밀롤재고
             WHERE A.WRK_ORDR_NO    = B.WRK_ORDR_NO
               AND A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO 
               AND A.WERKS          = C.WERKS
               AND A.MATNR          = C.MATNR 
               AND A.CUTTER         = D.MACH_CD(+)
               AND A.MACH_CD        = E.MACH_CD
               AND E.PROC_CD        = ''CA''   
               AND A.WERKS          = F1.WERKS(+)
               AND A.IND_BCD        = F1.IND_BCD(+)
               AND F1.WERKS         = F.WERKS (+) 
               AND F1.IND_BCD_M      = F.IND_BCD (+) 
               AND F.MACH_CD        = G.MACH_CD(+)
               AND G.PROC_CD  (+)   = ''MA''               
               AND A.KUNNR          = H.CUST_CD(+)
               AND H.CUST_DIV(+)   = ''C''
               AND A.WERKS          = I.WERKS(+)
               AND A.IND_BCD        = I.IND_BCD(+)
			   AND F.IND_BCD		= MRI.IND_BCD(+)
               --AND NVL(A.CNL_YN,''N'')   = ''N''
                AND J.ORDER_NO      = B.PRE_ORDER_NO(+)';

			--V_SQL := V_SQL || ' AND FN_RECDATE(A.PRD_STR_DATE) >= '''|| V_SDATE || ''''; --생산시작일자
			
            V_SQL := V_SQL || ' AND A.PRFM_DT = ''' || V_PRFM_DT || '''';		--실적일자   
               
            IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN
            	V_SQL := V_SQL || ' AND B.PCODE =  ''' || V_PCODE || '''';                  --지종				      
        	END IF;

            IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN
            	V_SQL := V_SQL || ' AND B.BS_WGT =  ''' || V_BS_WGT || '''';                --평량				      
        	END IF;

            IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN
            	V_SQL := V_SQL || ' AND A.MATNR =  ''' || V_MATNR || '''';    
        	END IF;

            IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND A.MACH_CD =  ''' || V_MACH_CD || '''';
        	END IF;

            --20220928 여한진 취소여부 검색조건 추가
            IF (V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '') THEN                          --취소여부
            	V_SQL := V_SQL || ' AND NVL(A.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
        	END IF;

            --IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN
           -- 	V_SQL := V_SQL || ' AND B.WLEN =  ''' || V_WLEN || '''';                    --가로길				      
        --	END IF;

           -- IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN
           -- 	V_SQL := V_SQL || ' AND B.VLEN =  ''' || V_VLEN || '''';                    --세로길				      
        	--END IF;

        	V_SQL := V_SQL || ' ORDER BY A.PRD_DT,  A.IND_BCD ';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';

	/*EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    	-- 에러 내역 SET
    	P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);*/
END;

/
