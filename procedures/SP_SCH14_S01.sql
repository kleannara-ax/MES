
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH14_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH14_S01
 * PROGRAM NAME  : 재단, 수재단 작업지시
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재단, 수재단 작업지시 를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/05/03
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH017] : (CRUD) 재단, 수재단 작업지시 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH14_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기
    V_PCODE         TB_SCH017.PCODE%TYPE;       --지종
	V_BS_WGT        TB_SCH017.BS_WGT%TYPE;      --평량
	V_VBELN			TB_SCH017.VBELN%TYPE;		--판매문서

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_WRK_ORDR_NO	       TB_SCH017.WRK_ORDR_NO%TYPE;        --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_SCH017.WRK_ORDR_SEQNO%TYPE;     --작업지시순번
    V_ORDER_NO	           TB_SCH017.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH017.WRK_ORDR_QTY%TYPE;       --지시수량
    V_ORDR_GEN_DT	       TB_SCH017.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH017.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH017.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH017.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH017.COMP_YN%TYPE;            --확정여부
    V_WRK_SEQNO            TB_SCH017.WRK_SEQNO%TYPE;          --작업순서  
    V_CUTTER               VARCHAR(2);                        --재단구분     

    V_MATNR	           	   TB_SCH017.MATNR%TYPE;              --자재코드
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_MACHINE            :=       V_JSON.get_string('MACHINE');      --생산호기
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--자재코드, 생산요청일자, 지시생성일자

   V_MATNR 		    	:=       V_JSON.get_string('MATNR');   		--자재코드
   V_CUTTER             :=       V_JSON.get_string('CUTTER');       --재단구분
   V_PCODE	        	:=		V_JSON.get_string('PCODE');			--지종코드
   V_BS_WGT          	:=		V_JSON.get_string('BS_WGT');		--평량
   V_VBELN				:=		V_JSON.get_string('VBELN');			--판매문서    

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT
                       SCH017.WERKS       		 WERKS            		--플랜트코드
	                 , SCH017.ORDR_GEN_DT 		 ORDR_GEN_DT			--작업지시일자
	                 , SCH017.WRK_ORDR_NO 		 WRK_ORDR_NO			--작업지시번호
                     , SCH017.WRK_ORDR_SEQNO 	 WRK_ORDR_SEQNO			--지시순번
	                 , SCH017.WRK_ORDR_QTY		 WRK_ORDR_QTY			--지시량
                     ,''R''                 AS CRUNIT                   --지시량 단위 - 추가
	                 , SCH017.ORDER_NO       	 ORDER_NO				--오더번호
                     , SCH017.WRK_SEQNO          WRK_SEQNO				--작업순서
                     , CASE WHEN NVL(SCH017.MAN_CUT_YN,''N'') = ''X'' THEN	(SELECT PRE_ORDER_NO FROM TB_SCH017 WHERE ORDER_NO = SCH017.PRE_ORDER_NO AND NVL(MAN_CUT_YN, ''N'') = ''Y'')  
							ELSE SCH017.PRE_ORDER_NO
						END PRE_ORDER_NO           --이전오더번호
--                     , SCH017.PRE_ORDER_NO	     PRE_ORDER_NO           --이전오더번호
	                 , SCH017.PRD_REQ_DT 		 PRD_REQ_DT			    --생산요청일자
	                 , SCH017.MACHINE     		 MACHINE				--생산호기
	                 , SCH017.MATNR       		 MATNR					--자재코드
	                 , MAS001.MATNR_NM		     MATNR_NM				--자재명
                     , SCH017.PCODE              PCODE                  --지종
                     , SCH017.BS_WGT             BS_WGT                 --평량
                     , SCH017.WLEN               WLEN	                --가로길이
                     , SCH017.VLEN	             VLEN                   --세로길이					 
                     , SCH017.TOT_WGT            TOT_WGT                --총중량
                     , ''KG''                    WUNIT                  --중량단위  --추가 
					 , SCH017.UNIT               UNIT                   --단위      
                     , SCH017.WLEN || ''*'' || SCH017.VLEN         REWD_SPEC              --Rewinder규격
                     , SCH017.IN_PER_CNT         ZZATT2	                --속당매수
                     , SCH017.CUTTER	         CUTTER                 --카터
                     , SCH017.ORDER_DIV
                     , SCH017.ORDER_DIV_NM
					 , SCH017.VBELN				 VBELN					--판매문서
					 , SCH017.POSNR			     POSNR					--판매문서항목번호
                     , FN_CD_VAL(''PACK_TYPE'', SCH017.PACKTYPE)           PACKTYPE	            --포장방법
                     , SCH017.KUNNRT             KUNNR	                --판매처
                     , TO_DATE(SCH017.PRD_STR_DTM, ''YYYY-MM-DD HH24:MI:SS'')        
                                                 PRD_STR_DTM            --생산시작시간					 
                     , CASE WHEN SCH017.PCODE = ''RP1''	THEN	SCH017.MAUFNR ELSE ''''	END             LOT_NO                 --LOT 번호
--                     , SCH017.MAUFNR             LOT_NO                 --LOT 번호
	                 , NVL(SCH017.COMP_YN,''N'') COMP_YN				--작업지시완료 (N:대기 I:작업중 Y:완료)
                     , NVL(FN_CMCDV(''COMP_YN'',SCH017.COMP_YN ),''대기'')
                                                 COMP_YN_NM			    --작업지시완료명 (N:대기 I:작업중 Y:완료)                     
                     , SCH017.ORDER_RMK	         PLN_ORDR_REMARK        --계획오더비고                     
	                 , CASE WHEN NVL(SCH017.MAN_CUT_YN, ''N'') = ''Y'' THEN ''[수재단이동]'' || CHR(13) || CHR(10) || SCH017.WRK_ORDR_RMK ELSE SCH017.WRK_ORDR_RMK END       WRK_ORDR_REMARK		--작업지시비고
                     , CASE  WHEN NVL(SCH017.MAN_CUT_YN,''N'') = ''X''  THEN ''수재단''
                             WHEN NVL(SCH017.MAN_CUT_YN,''N'') IN (''Y'', ''N'')  THEN ''재단''
                             ELSE                                            ''재단''
                        END                      MAN_CUT_YN             --수재단여부
	                 , SCH017.REGDATE            REGDATE				--등록일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH017.REGID),'''')	             
                                                 REGNM					--등록자
	                 , SCH017.UPDDATE            UPDDATE				--수정일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH017.UPDID),'''')				 
                                                 UPDNM					--수정자
                     , NVL(SCH017.USE_YN,''Y'')  USE_YN				    --사용여부
                FROM TB_SCH017   SCH017   -- 작업지시 재단
                   , TB_MAS001   MAS001   -- 플랜트별 제품/자재 마스터
               WHERE SCH017.MATNR = MAS001.MATNR(+) 
                 AND SCH017.WERKS  = MAS001.WERKS(+)  '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH017.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH017.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

        IF  V_CUTTER = 'C' THEN
            V_SQL := V_SQL || ' AND NVL(SCH017.MAN_CUT_YN,''N'') IN (''Y'', ''N'') ';			   	   --재단 
        ELSIF V_CUTTER = 'S' THEN
            V_SQL := V_SQL || ' AND NVL(SCH017.MAN_CUT_YN,''N'') = ''X''';			   	   --수재단 
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'SCH017.MATNR');	--자재코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'SCH017.PCODE');	--지종코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'SCH017.BS_WGT');	--평량
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               
        END IF; 

        V_SQL := V_SQL || ' ORDER BY SCH017.WRK_ORDR_NO,SCH017.WRK_SEQNO, SCH017.WRK_ORDR_SEQNO';  
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
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
            V_ORDER_NO	                := V_OBJ.get_string('ORDER_NO');           --오더번호
            V_ORDR_QTY	                := V_OBJ.get_string('WRK_ORDR_QTY');       --지시수량
            V_ORDR_GEN_DT	            := V_OBJ.get_string('ORDR_GEN_DT');        --지시생성일자
            V_PRD_REQ_DATE	            := V_OBJ.get_string('PRD_REQ_DT');         --생산요청일자
            V_WRK_ORDR_REMARK	        := V_OBJ.get_string('WRK_ORDR_REMARK');    --작업지시비고
            V_USE_YN	                := V_OBJ.get_string('USE_YN');             --사용여부
            V_COMP_YN	                := V_OBJ.get_string('COMP_YN');            --확정여부
            V_WRK_SEQNO	                := V_OBJ.get_string('WRK_SEQNO');          --작업순서

            IF V_OBJ.get_string('GRowState') = 'C'   THEN
                SELECT NVL(MAX(WRK_ORDR_SEQNO) + 1, 1)
                  INTO V_WRK_ORDR_SEQNO
                  FROM TB_SCH017
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO ;

                INSERT INTO TB_SCH017 (
                      WRK_ORDR_NO	        --작업지시번호
                    , WRK_ORDR_SEQNO	    --작업지시순번
                    , WERKS	                --플랜트코드
                    , ORDER_NO	            --오더번호
                    , WRK_SEQNO	            --작업순서                    
                    , WRK_ORDR_QTY          --지시수량
                    , ORDR_GEN_DT	        --지시생성일자
                    , PRD_REQ_DT	        --생산요청일자
                    , WRK_ORDR_RMK  	    --작업지시비고
                    , PRD_STR_DTM	        --생산시작일시
                    , PRD_END_DTM	        --생산완료일시
                    , PRFM_QTY	            --완료수량
                    , COMP_YN	            --완료여부
                    , USE_YN	            --사용여부
                    , PRE_ORDER_NO          --밀롤 오더 번호
                    --, BUDAT	                --시작일자
                    , ORDER_DIV             --오더유형
                    , ORDER_DIV_NM          --오더유형 텍스트
                    , MACHINE	            --FROM 생산호기
                    , MACHINE_NM	        --FROM 생산 호기명
                    , TO_MACHINE            --TO 생산호기
                    , TO_MACHINE_NM	        --TO 생산 호기명
                    , MATNR	                --재단 자재 코드
                    , PCODE	                --지종
                    , BS_WGT	            --평량
                    , WLEN	                --가로길이
                    , VLEN	                --세로길이
                    , PKCNT	                --폭수
                    --, CNT	                --수량
                    , TOT_WGT	            --총중량
                    --, CGEWEI	            --단위
                    , PLT_PER_CNT           --팔레트당연수
                    , IN_PER_CNT            --속당매수
                    , DBL_FLAG   	        --쌍팔레트
                    , VBELN	                --판매문서
                    , POSNR	                --판매문서 항목번호
                    , SAUART_DIV            --판매문서 유형
                    , SAUART_NM	            --판매 문서 오더 유형 텍스트
                    , OVBELN	            --판매문서
                    , OPOSNR	            --판매문서 항목번호
                    , OAUART_DIV            --판매문서 유형
                    , OAUART_NM	            --판매 문서 오더 유형 텍스트
                    , CUTTER	            --카터
                    , BOM_NO                --BOM Num
                    , ATN_BOM_NO            --대체Bom
                    , PRT_MATNR_QTY         --모품목기준수량
                    , PRT_MATNR_UNIT        --모품목기준수량 단위
                    , DLFL	                --오더 삭제 지시자
                    , REGDATE	            --등록일시
                    , REGID	                --등록자ID
                    , UPDDATE	            --수정일시
                    , UPDID	                --수정자ID
                ) 
                SELECT 
                      SCH017.WRK_ORDR_NO	--작업지시번호
                    , V_WRK_ORDR_SEQNO	    --작업지시순번
                    , V_WERKS	            --플랜트코드
                    , V_ORDER_NO	        --오더번호
                    , V_WRK_SEQNO    	    --작업순서                     
                    , V_ORDR_QTY	        --지시수량
                    , V_ORDR_GEN_DT	        --지시생성일자
                    , V_PRD_REQ_DATE	    --생산요청일자
                    , V_WRK_ORDR_REMARK	    --작업지시비고
                    , NULL       	        --생산시작일시
                    , NULL	                --생산완료일시
                    , NULL	                --완료수량
                    , 'N'	                --완료여부
                    , 'Y'	                --사용여부
                    , SCH017.PRE_ORDER_NO	--밀롤 오더 번호
                    --, SCH017.BUDAT          --시작일자
                    , SCH017.ORDER_DIV      --오더유형
                    , SCH017.ORDER_DIV_NM   --오더유형 텍스트
                    , SCH017.MACHINE        --FROM 생산호기
                    , SCH017.MACHINE_NM     --FROM 생산 호기명
                    , SCH017.TO_MACHINE	    --TO 생산호기
                    , SCH017.TO_MACHINE_NM  --TO 생산 호기명
                    , SCH017.MATNR	        --자재 코드
                    , SCH017.PCODE	        --지종
                    , SCH017.BS_WGT	        --평량
                    , SCH017.WLEN	        --가로길이
                    , SCH017.VLEN	        --세로길이
                    , SCH017.PKCNT	        --폭수
                    --, SCH017.CNT	        --수량
                    , SCH017.TOT_WGT        --총중량
                    --, SCH017.CGEWEI	        --단위
                    , SCH017.PLT_PER_CNT    --팔레트당연수
                    , SCH017.IN_PER_CNT     --속당매수
                    , SCH017.DBL_FLAG       --쌍팔레트
                    , SCH017.VBELN	        --판매문서
                    , SCH017.POSNR	        --판매문서 항목번호
                    , SCH017.SAUART_DIV     --판매문서 유형
                    , SCH017.SAUART_NM      --판매 문서 오더 유형 텍스트
                    , SCH017.VBELN  	    --판매문서
                    , SCH017.OPOSNR	        --판매문서 항목번호
                    , SCH017.OAUART_DIV     --판매문서 유형
                    , SCH017.OAUART_NM	    --판매 문서 오더 유형 텍스트
                    , SCH017.CUTTER	        --카터
                    , SCH017.BOM_NO	        --BOM Num
                    , SCH017.ATN_BOM_NO     --대체Bom
                    , SCH017.PRT_MATNR_QTY	--모품목기준수량
                    , SCH017.PRT_MATNR_UNIT	--모품목기준수량 단위
                    , SCH017.DLFL	        --오더 삭제 지시자
                    , SYSDATE	            --등록일시
                    , V_SESS_USER_ID	    --등록자ID
                    , NULL	                --수정일시
                    , NULL	                --수정자ID
                  FROM TB_SCH017 SCH017
                 WHERE SCH017.WRK_ORDR_NO = V_WRK_ORDR_NO	                      --작업지시번호
                   AND ROWNUM = 1
                 ;

            ELSIF V_OBJ.get_string('GRowState') = 'U'  THEN

                -- 완료여부 : N:대기 I:작업중 Y:완료
                SELECT COMP_YN
                  INTO V_COMP_YN
                  FROM TB_SCH017
                 WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO 
                   AND WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO   ; 

                IF NVL(V_COMP_YN,'N') = 'N' THEN   -- N:대기 경우일때만 변경 실행
                    UPDATE TB_SCH017 
                    SET   WRK_ORDR_QTY      = V_ORDR_QTY                    --지시량
                         ,WRK_SEQNO         = V_WRK_SEQNO    	            --작업순서                     
                         ,WRK_ORDR_RMK      = V_WRK_ORDR_REMARK             --작업지시비고
                         ,UPDDATE		    = SYSDATE			            --수정일자
                         ,UPDID			    = V_SESS_USER_ID	            --수정자   
                         ,USE_YN            = V_USE_YN                      --사용여부   (Y:사용 N:미사용)
                    WHERE WRK_ORDR_NO		= V_WRK_ORDR_NO    AND			--작업지시번호
                          WRK_ORDR_SEQNO    = V_WRK_ORDR_SEQNO   ;          --작업지시순번            
                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'D'  THEN
               RETURN ;   
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
