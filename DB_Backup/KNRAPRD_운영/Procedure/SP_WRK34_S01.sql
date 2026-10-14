--------------------------------------------------------
--  DDL for Procedure SP_WRK34_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK34_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS        OUT    varchar2,
    P_CODE           OUT    VARCHAR2 ,
    P_MSG            OUT    VARCHAR2 ,
	P_RS_LIST        OUT    SYS_REFCURSOR,
    P_DOC_NO         OUT    varchar2 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK34_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 예외생산{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/14 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS009] : (.R..) 거래처정보
 * 		 - [TB_MAS028] : (.R..) 로케이션
 *       - [TB_INV001] : (.R..) 재고
*        - [TB_MAS001] : (.R..) 자재
 *	     - [TB_SCH017] : (.R..) 작업지시 재단                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK34_S01';     -- PROCEDURE NAME

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
    V_WERKS			TB_SCH019.WERKS%TYPE;		--플랜트
    V_SDATE         varchar(10);                --시작지시일자  
    V_EDATE         varchar(10);                --종료지시일자  
    V_PROC_CD       varchar(10);                --공정코드  

    V_WRK_ORDR_NO     TB_SCH019.WRK_ORDR_NO%TYPE;     --작업지시번호
    V_WRK_ORDR_SEQNO  TB_SCH019.WRK_ORDR_SEQNO%TYPE;  --작업지시순번


    V_MACHINE		TB_INV001.MACHINE%TYPE;
    V_PCODE 		TB_MAS001.PCODE%TYPE;      
    V_BS_WGT        TB_MAS001.BS_WGT%TYPE;
    V_WLEN          TB_SCH017.WLEN%TYPE;
    V_VLEN          TB_SCH017.VLEN%TYPE;
    V_BCD           TB_INV001.IND_BCD%TYPE;
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        

   V_MACH_CD        varchar(8);             --설비코드 
   V_PRFM_QTY       NUMBER;          --실적수량 

   V_PRD_STR_DT     varchar(8);                         --시작일자 
   V_PRD_STR_TM     varchar(4);                         --시작시간                          
   V_PRD_END_DT     varchar(8);                         --종료일자 
   V_PRD_END_TM     varchar(4);                         --종료시간                          
   V_MATNR          TB_SCH019.MATNR%TYPE;               --자재코드
   V_IND_BCD        TB_INV003.IND_BCD%TYPE;             --업체/개별 바코드
   V_INP_QTY        TB_INV003.IN_QTY%TYPE;              --투입수량
   V_UNIT           TB_INV003.UNIT%TYPE;                --단위
   V_PRFM_UNIT      TB_INV003.UNIT%TYPE;                --실적단위
   V_LOT_NO         TB_INV001.LOT_NO%TYPE;              --LOT_NO
   V_MATNR_1        TB_SCH019.MATNR%TYPE;               --품명
   V_COMP_YN        TB_SCH019.COMP_YN%TYPE;             --처리완료
   V_LOT_NO_BUF     TB_SCH019.LOT_NO_BUF%TYPE;          --LOT NO BUF
   V_ORDER_NO       TB_SCH019.ORDER_NO%TYPE;            --오더번호

   V_DOC_NO         VARCHAR2(20);
   V_DOC_SEQNO      NUMBER;
   V_RUECK	        VARCHAR2(10 BYTE);	                --SAP 확정번호
   V_RMZHL	        VARCHAR2(8 BYTE);	                --SAP 확정카운터 
   V_CONF			VARCHAR2(1);						--오더 완료 여부   

   V_STOR_LOC_CD    TB_INV001.STOR_LOC_CD%TYPE;  --저장위치

   V_NUM            NUMBER;   
   V_SEQNO          TB_INV003.SEQNO%TYPE; 

   --실적 등록시 사용
   V_PLTBOX         NUMBER;
   V_IND_QTY        NUMBER;
   V_PRFM_TEMP      TB_WRK001.PRFM_QTY%TYPE;
   V_PRFM_PLT       TB_WRK001.PLT_QTY%TYPE;
   V_PRFM_BOX       TB_WRK001.BOX_QTY%TYPE;
   V_PRFM_BAG       TB_WRK001.BAG_QTY%TYPE;
   V_PRFM_EA        TB_WRK001.EA_QTY%TYPE;
   V_PRFM_KG        TB_WRK001.WGT%TYPE;
   V_COMP           TB_WRK001.COMP_YN%TYPE;
   V_WRK_CLASS      TB_WRK001.WRK_CLASS%TYPE;
   V_DSTBT_DDLIN    VARCHAR(10); --유통기간 일자
   V_DSTBT_DAYS     NUMBER(4); --유통기간
   V_CNT            NUMBER;--반복횟수
   V_DOC_USE        VARCHAR2(20);
   V_TM_SEC         VARCHAR(2);--실적 등록시 초단위 정보
   V_STR_DATE       DATE;
   V_END_DATE       DATE;
   V_ERR_LIST       VARCHAR2(4000); --수량 부족항목목록
   V_DATE          DATE;
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
   V_WERKS          	:=       V_JSON.get_string('WERKS');	       --플랜트    
   V_SDATE              :=       V_JSON.get_string('SDATE');	       --시작지시일자  
   V_EDATE              :=       V_JSON.get_string('EDATE');	       --종료지시일자  
   V_PROC_CD            :=       V_JSON.get_string('PROC_CD');         --공정코드  
   V_WRK_ORDR_NO        :=       V_JSON.get_string('WRK_ORDR_NO');     --작업지시번호
   V_WRK_ORDR_SEQNO     :=       V_JSON.get_string('WRK_ORDR_SEQNO');  --작업지시순번

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  SCH019.WERKS                             WERKS               --플랜트
                         , SCH019.ORDER_NO                          ORDER_NO            --오더번호
                         , SCH019.ORDER_DIV                         ORDER_DIV           --오더유형
                         , FN_CMCDV (''ORDER_DIV'', SCH019.ORDER_DIV )   
                                                                    ORDER_DIV_NM        --오더유형명
                         , SCH019.WRK_ORDR_NO                       WRK_ORDR_NO         --작업지시번호
                         , SCH019.WRK_ORDR_SEQNO                    WRK_ORDR_SEQNO      --작업지시순번
                         , SCH019.PRD_REQ_DT	                    PRD_REQ_DT          --생산요청일자
                         , SCH019.MACH_CD                           MACH_CD             --설비코드 
                         , MAS012.MACH_NM                           MACH_NM             --설비명 
                         , CEIL(FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, ''BOX'', ''BOX'',NVL(SCH019.COMP_QTY,0)))                   
                                                                   PRFM_QTY            --실적수량 
                         , CEIL(FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''PAL'',NVL(SCH019.WRK_ORDR_QTY,0)))                      
                                                                   PLT_PRFM_QTY            --PLT실적수량
                         , CEIL(FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''BOX'',NVL(SCH019.WRK_ORDR_QTY,0)))                      
                                                                   BOX_PRFM_QTY            --BOX실적수량
                         , CEIL(FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''BAG'',NVL(SCH019.WRK_ORDR_QTY,0)))                      
                                                                   BAG_PRFM_QTY            --BAG실적수량
                         , CEIL(FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''EA'',NVL(SCH019.WRK_ORDR_QTY,0)))                      
                                                                   EA_PRFM_QTY            --EA실적수량
                         , FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''R'',NVL(SCH019.COMP_QTY,0))                      
                                                                   R_PRFM_QTY             --R실적수량
                         , FN_CHG_UNIT(SCH019.MATNR, SCH019.WERKS, SCH019.UNIT, ''KG'',NVL(SCH019.COMP_QTY,0))                      
                                                                   KG_PRFM_QTY             --KG실적수량
                         , SUBSTR(SCH019.PRD_STR_DTM,1,8) PRD_STR_DT          --시작일자 
                         , SUBSTR(SCH019.PRD_STR_DTM,9,6)   PRD_STR_TM          --시작시간                          
                         , SUBSTR(SCH019.PRD_END_DTM,1,8) PRD_END_DT          --종료일자 
                         , SUBSTR(SCH019.PRD_END_DTM,9,6)   PRD_END_TM          --종료시간                          
                         , SCH019.MATNR                             MATNR               --품목
                         , MAS001.MATNR_NM                          MATNR_NM            --품목명
                         , SCH019.UNIT                              UNIT                --단위
                         , ''BOX''                                  PRFM_UNIT           --실적단위
                         , SCH019.GAMNG                             ORDER_QTY           --오더량
                         , SCH019.WRK_ORDR_QTY                      WRK_ORDR_QTY        --생산지시량
                         , SCH019.COMP_YN                           COMP_YN             --처리완료
                         , FN_CMCDV (''COMP_YN'', SCH019.COMP_YN)   COMP_YN_NM          --처리완료명
                         , SCH019.SCNT                              SCNT                --속수
                         , SCH019.BMENG                             TOT_WGT             --총중량
                         , SCH019.LOT_NO_BUF                        LOT_NO_BUF          --LOT_NO_BUF
                      FROM TB_SCH019      SCH019       --작업지시 예외생산
                         , TB_MAS001      MAS001       --플랜트별 제품/자재 마스터
                         , TB_MAS012      MAS012       --설비 마스터
                      WHERE SCH019.MATNR   = MAS001.MATNR(+) 
                        AND SCH019.WERKS   = MAS001.WERKS(+)    
                        AND SCH019.MACH_CD = MAS012.MACH_CD(+)    
                        ';        

        IF	V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
			V_SQL := V_SQL || ' AND SCH019.WERKS = ''' || V_WERKS || '''' ; 	--플랜트
		END IF;

        --IF	V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
		--	V_SQL := V_SQL || ' AND MAS013.PROC_GRP_CD = ''' || V_PROC_CD || '''' ; 	--공정코드
		--END IF;

        V_SQL := V_SQL || ' AND SCH019.PRD_REQ_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''' ; 	--지시일자  

        V_SQL := V_SQL || ' AND SCH019.ORDER_DIV   IN (''ZP22'', ''ZP32'',''ZP52'')' ; 	--오더유형

        V_SQL := V_SQL || ' ORDER BY SCH019.PRD_REQ_DT,SCH019.WRK_ORDR_NO ,SCH019.WRK_ORDR_SEQNO,SCH019.WERKS ' ; 	--지시일자  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* 하단 좌측 조회 리스트*/
        V_SQL := ' SELECT  SCH020.MATNR            MATNR           --자재
                         , MAS001.MATNR_NM         MATNR_NM        --자재명
                         , SCH020.ORDER_BOM_QTY    INP_QTY         --투입량
                         , SCH020.UNIT             UNIT            --단위
                         , SCH020.WERKS            WERKS           --플랜트  
                         , SCH020.WRK_ORDR_NO      WRK_ORDR_NO     --작업지시번호
                         , SCH020.WRK_ORDR_SEQNO   WRK_ORDR_SEQNO  --작업지시순번
                         , SCH019.MACH_CD          MACH_CD         --설비코드    
                      FROM TB_SCH020  SCH020     --작업지시 BOM
                         , TB_MAS001  MAS001     --플랜트별 제품/자재 마스터
                         , TB_SCH019  SCH019     --작업지시 예외생산
                     WHERE SCH020.MATNR   = MAS001.MATNR(+) 
                       AND SCH020.WERKS   = MAS001.WERKS(+)  
                       AND SCH020.WRK_ORDR_NO    = SCH019.WRK_ORDR_NO(+)
                       AND SCH020.WRK_ORDR_SEQNO = SCH019.WRK_ORDR_SEQNO(+)
                        ';        

        IF	V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
			V_SQL := V_SQL || ' AND SCH020.WERKS = ''' || V_WERKS || '''' ; 	--플랜트
		END IF;

        IF	V_WRK_ORDR_NO IS NOT NULL OR TRIM(V_WRK_ORDR_NO) != '' THEN
			V_SQL := V_SQL || ' AND SCH020.WRK_ORDR_NO  = ''' || V_WRK_ORDR_NO || '''' ; 	   --작업지시번호
		END IF;

        IF	V_WRK_ORDR_SEQNO IS NOT NULL OR TRIM(V_WRK_ORDR_SEQNO) != '' THEN
			V_SQL := V_SQL || ' AND SCH020.WRK_ORDR_SEQNO  = ''' || V_WRK_ORDR_SEQNO || '''' ; 	--작업지시순번
		END IF;



        V_SQL := V_SQL || ' ORDER BY SCH020.MATNR ' ; 	  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST2' THEN  /* 하단 우축 조회 리스트*/
        V_SQL := '      SELECT INV003.MATNR                 MATNR           --자재
                             , MAS001.MATNR_NM              MATNR_NM        --자재명
                             , INV003.IND_BCD	            IND_BCD         --개별바코드
                             , STCK_QTY                 	STCK_QTY        --재고수량
                             , NULL                         INP_QTY_TOT     --투입수량합계
                             , IN_QTY                       INP_QTY         --투입수량   
                             , INV003.UNIT                  UNIT            --단위
                             , NULL /*INV001.STOR_LOC_CD*/	        STOR_LOC_CD     --저장위치
                             , NULL /*MAS003.STOR_LOC_NM*/	        STOR_LOC_NM     --저장위치명
                             , INV003.WERKS                 WERKS           --플랜트 
                             , INV003.MACH_CD               MACH_CD         --설비코드
                             , INV003.WRK_ORDR_NO           WRK_ORDR_NO     --작업지시번호
                             , INV003.WRK_ORDR_SEQNO        WRK_ORDR_SEQNO  --작업지시순번
                             , NULL /*INV001.LOT_NO/*                LOT_NO          --LOT_NO
                             , NULL  /*SCH019.MATNR  */               MATNR_1         --품명
                             , INV003.SEQNO                           SEQNO
                          FROM TB_INV003  INV003     --자재투입
                             , TB_MAS001  MAS001     --플랜트별 제품/자재 마스터
                         WHERE  1 = 1
                           AND INV003.MATNR   = MAS001.MATNR(+) 
                           AND INV003.WERKS   = MAS001.WERKS(+)   
                           AND INV003.STCK_QTY > 0
                            ';        

        IF	V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
			V_SQL := V_SQL || ' AND INV003.WERKS = ''' || V_WERKS || '''' ; 	--플랜트
		END IF;

        IF	V_WRK_ORDR_NO IS NOT NULL OR TRIM(V_WRK_ORDR_NO) != '' THEN
			V_SQL := V_SQL || ' AND INV003.WRK_ORDR_NO  = ''' || V_WRK_ORDR_NO || '''' ; 	   --작업지시번호
		END IF;

        IF	V_WRK_ORDR_SEQNO IS NOT NULL OR TRIM(V_WRK_ORDR_SEQNO) != '' THEN
			V_SQL := V_SQL || ' AND INV003.WRK_ORDR_SEQNO  = ''' || V_WRK_ORDR_SEQNO || '''' ; 	--작업지시순번
		END IF;

        --V_SQL := V_SQL || ' ORDER BY SCH020.MATNR ' ; 	  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST3' THEN  /* POP UP 조회 리스트*/
        V_ARR_LIST        := V_JSON.get_array('list2');

        V_OBJ						:= TREAT (V_ARR_LIST.get (0) AS json_object_t);  
        V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

        V_MATNR                     := V_OBJ.get_string('MATNR');          --자재코드
        V_WERKS          	        := V_OBJ.get_string('WERKS');	       --플랜트   
        V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');     --작업지시번호
        V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');  --작업지시순번


        V_SQL := '      SELECT INV001.MATNR                 MATNR           --자재
                             , MAS001.MATNR_NM              MATNR_NM        --자재명
                             , INV001.STOR_LOC_CD	        STOR_LOC_CD     --저장위치
                             , MAS003.STOR_LOC_NM	        STOR_LOC_NM     --저장위치명
                             , INV001.IND_BCD	            IND_BCD         --개별바코드
                             , INV001.UNIT                  UNIT            --단위
                             , INV001.STCK_QTY        	    STCK_QTY        --재고수량
                             , NULL                         INP_QTY_TOT     --투입수량합계
                             , 0                            INP_QTY         --투입수량   
                          FROM TB_INV001  INV001     --창고별 재고현황
                             , TB_MAS003  MAS003     --저장위치 마스터(공정창고내 저장위치 포함)
                             , TB_MAS001  MAS001     --플랜트별 제품/자재 마스터
                         WHERE  1 = 1
                           AND INV001.WERKS         = MAS003.WERKS(+)  
                           AND INV001.STOR_LOC_CD   = MAS003.STOR_LOC_CD(+) 
                           AND INV001.MATNR         = MAS001.MATNR(+) 
                           AND INV001.WERKS         = MAS001.WERKS(+) 
                            ';        

        IF	V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
			V_SQL := V_SQL || ' AND INV001.INV001 = ''' || V_WERKS || '''' ; 	--플랜트
		END IF;

        IF	V_WRK_ORDR_NO IS NOT NULL OR TRIM(V_WRK_ORDR_NO) != '' THEN
			V_SQL := V_SQL || ' AND INV001.MATNR  = ''' || V_MATNR || '''' ; 	   --자재코드
		END IF;

        --V_SQL := V_SQL || ' ORDER BY SCH020.MATNR ' ; 	  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN  --공정투입(사용안함)
        V_ARR_LIST        := V_JSON.get_array('list1');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');            --설비코드
            V_MATNR                     := V_OBJ.get_string('MATNR');              --자재코드
            V_IND_BCD                   := V_OBJ.get_string('IND_BCD');            --업체/개별 바코드
            V_INP_QTY                   := V_OBJ.get_string('INP_QTY');            --투입수량
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');        --작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');     --작업지시순번  
            V_UNIT                      := V_OBJ.get_string('UNIT');               --단위  
            V_LOT_NO                    := V_OBJ.get_string('LOT_NO');             --LOT_NO
            V_MATNR_1                   := V_OBJ.get_string('MATNR_1');            --품번
            V_STOR_LOC_CD               := V_OBJ.get_string('STOR_LOC_CD');        --저장위치

            IF	V_MACH_CD IS  NULL OR TRIM(V_MACH_CD) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '설비코드를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            V_DOC_NO := FN_GET_MDOCNO('M', 'IF139');
            V_DOC_SEQNO := 1;

            SELECT ORDER_NO
            INTO V_ORDER_NO 
            FROM TB_SCH019  SCH019  
            WHERE SCH019.WRK_ORDR_NO    = V_WRK_ORDR_NO
              AND SCH019.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
            ;  

            V_NUM := 0 ;

            SELECT  NVL(MAX(SEQNO), 0) +1
            INTO V_NUM
            FROM TB_INV003        --자재투입
            WHERE WERKS     = V_WERKS
              AND MACH_CD   = V_MACH_CD
              AND MATNR     = V_MATNR
            ;   

           UPDATE TB_INV003
              SET IN_QTY = NVL(IN_QTY,0) + V_INP_QTY
                , STCK_QTY = NVL(STCK_QTY,0) + V_INP_QTY
                , UPDDATE = SYSDATE
                , UPDID = V_SESS_USER_ID
            WHERE 1=1
              AND WERKS = V_WERKS
              AND MACH_CD = V_MACH_CD
              AND MATNR = V_MATNR
              AND IND_BCD = V_IND_BCD;
           IF SQL%ROWCOUNT = 0 THEN
               INSERT INTO TB_INV003     --자재투입 
               (
                     WERKS	        --플랜트 코드
                    ,MACH_CD	    --설비코드
                    ,MATNR	        --자재코드
                    ,IND_BCD	    --업체/개별 바코드
                    ,SEQNO	        --순번
                    ,WRK_ORDR_NO	--작업지시번호
                    ,WRK_ORDR_SEQNO	--작업지시순번
                    ,LOT_NO	        --LOT_NO
                    ,INP_DT	        --투입일자
                    ,IN_QTY	        --투입량
                    ,USE_QTY	    --사용량
                    ,STCK_QTY	    --재고량
                    ,UNIT	        --단위
                    ,ROLLCNT	    --권치수(점보롤, 밀롤, 합지기)
                    ,WGT	        --중량(재단,포장공정)
                    ,CHG_FLG    	--대체여부
                    ,STCK_KY	    --WMS 지점코드
                    ,LOT_NUM	    --WMS LOT 속성 KY
                    ,REGDATE	    --등록일시
                    ,REGID	        --등록자
                    ,UPDDATE	    --수정일시
                    ,UPDID	        --수정자           
               ) VALUES (
                     V_WERKS	                            --플랜트 코드
                    ,V_MACH_CD	                            --설비코드
                    ,V_MATNR	                            --자재코드
                    ,V_IND_BCD	                            --업체/개별 바코드
                    ,V_NUM	                                --순번
                    ,V_WRK_ORDR_NO	                        --작업지시번호
                    ,V_WRK_ORDR_SEQNO	                    --작업지시순번
                    ,V_LOT_NO	                            --LOT_NO
                    ,TO_CHAR(SYSDATE,'YYYYMMDD')	        --투입일자
                    ,V_INP_QTY	                            --투입량
                    ,NULL	                                --사용량
                    ,V_INP_QTY	                            --재고량
                    ,V_UNIT	                                --단위
                    ,NULL	                                --권치수(점보롤, 밀롤, 합지기)
                    ,NULL	                                --중량(재단,포장공정)
                    ,NULL    	                            --대체여부
                    ,NULL	                                --WMS 지점코드
                    ,NULL	                                --WMS LOT 속성 KY
                    ,SYSDATE	                            --등록일시
                    ,V_SESS_USER_ID	                        --등록자
                    ,NULL	                                --수정일시
                    ,NULL	                                --수정자                      
               );
           END IF;
/*
           INSERT INTO TB_INV010     
           (
                     WERKS	            --플랜트 코드
                    ,MACH_CD	            --설비코드
                    ,MATNR	            --자재코드
                    ,IND_BCD	            --개별 바코드
                    ,SEQNO	            --순번
                    ,WRK_ORDR_NO	        --작업지시번호
                    ,WRK_ORDR_SEQNO	    --작업지시순번
                    ,LOT_NO	            --LOT NO
                    ,IND_BCD_M	        --투입자재의 업체/개별 바코드
                    ,LOT_NO_M	        --투입자재의 LOT NO
                    ,MATNR_M	            --투입자재의 자재코드
                    ,INP_DT	            --투입일자
                    ,PRFM_DT	            --실적일자
                    ,USE_QTY	            --사용량
                    ,UNIT	            --단위
                    ,ROLLCNT	            --권치수)점보롤, 밀롤, 합지기)
                    ,WGT	                --중량(재단,포장공정)
                    ,CHG_FLG	            --대체여부
                    ,STCK_KY	            --WMS 지점코드
                    ,LOT_NUM	            --WMS LOT 속성 KY
                    ,REGDATE	            --등록일시
                    ,REGID	            --등록자
                    ,UPDDATE	            --수정일시
                    ,UPDID	            --수정자
                    ,USE_DIV	            --자재사용구분(1: 정상,2: 보정)
                    ,DOC_NO	            --MES 문서번호
                    ,DOC_SEQNO	        --MES 문서번호 순번
                    ,SDOC_NO	            --SAP 확정문서번호
                    ,SDOC_SEQNO	        --SAP 확정카운터
                    ,CNL_YN	
                    ,CNL_RMK	
           ) VALUES (
                     V_WERKS	            --플랜트 코드
                    ,V_MACH_CD	            --설비코드
                    ,MATNR	            --자재코드
                    ,IND_BCD	            --개별 바코드
                    ,SEQNO	            --순번
                    ,WRK_ORDR_NO	        --작업지시번호
                    ,WRK_ORDR_SEQNO	    --작업지시순번
                    ,LOT_NO	            --LOT NO
                    ,IND_BCD_M	        --투입자재의 업체/개별 바코드
                    ,LOT_NO_M	        --투입자재의 LOT NO
                    ,MATNR_M	            --투입자재의 자재코드
                    ,INP_DT	            --투입일자
                    ,PRFM_DT	            --실적일자
                    ,USE_QTY	            --사용량
                    ,UNIT	            --단위
                    ,ROLLCNT	            --권치수)점보롤, 밀롤, 합지기)
                    ,WGT	                --중량(재단,포장공정)
                    ,CHG_FLG	            --대체여부
                    ,STCK_KY	            --WMS 지점코드
                    ,LOT_NUM	            --WMS LOT 속성 KY
                    ,REGDATE	            --등록일시
                    ,REGID	            --등록자
                    ,UPDDATE	            --수정일시
                    ,UPDID	            --수정자
                    ,USE_DIV	            --자재사용구분(1: 정상,2: 보정)
                    ,DOC_NO	            --MES 문서번호
                    ,DOC_SEQNO	        --MES 문서번호 순번
                    ,NULL	            --SAP 확정문서번호
                    ,NULL	            --SAP 확정카운터
                    ,'N'	
                    ,NULL
           );   

*/



            UPDATE TB_SCH019  SET              --작업지시 예외생산
                 COMP_YN          = 'I'             -- 완료여부(N:대기 I:작업중 Y:완료)         
                ,UPDDATE	      = SYSDATE         --수정일시
                ,UPDID	          = V_SESS_USER_ID  --수정자ID
            WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
            ;            
            P_DOC_NO := V_DOC_NO;

        END LOOP;
    ELSIF P_TYPE = 'SAVE3' THEN  --공정투입취소
        V_ARR_LIST        := V_JSON.get_array('list1');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');            --설비코드
            V_MATNR                     := V_OBJ.get_string('MATNR');              --자재코드
            V_IND_BCD                   := V_OBJ.get_string('IND_BCD');            --업체/개별 바코드
            V_INP_QTY                   := V_OBJ.get_string('INP_QTY');            --투입수량
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');        --작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');     --작업지시순번  
            V_UNIT                      := V_OBJ.get_string('UNIT');               --단위  
            V_LOT_NO                    := V_OBJ.get_string('LOT_NO');             --LOT_NO
            V_MATNR_1                   := V_OBJ.get_string('MATNR_1');            --품번
            V_STOR_LOC_CD               := V_OBJ.get_string('STOR_LOC_CD');        --저장위치
            V_SEQNO                     := V_OBJ.get_string('SEQNO');              --


            IF	V_MACH_CD IS  NULL OR TRIM(V_MACH_CD) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '설비코드를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

           DELETE FROM   TB_INV003     --자재투입
           WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
             AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
             AND IND_BCD        = V_IND_BCD
             AND WERKS          = V_WERKS
             AND MACH_CD        = V_MACH_CD
             AND SEQNO          = V_SEQNO
           ;  

--           UPDATE TB_INV001 SET STCK_QTY  =  STCK_QTY + V_INP_QTY
--            WHERE WERKS        =  V_WERKS
--              AND STOR_LOC_CD  =  V_STOR_LOC_CD 
--              AND IND_BCD      =  V_IND_BCD 
--              AND MATNR        =  V_MATNR
--           ; 

            BEGIN
                SELECT STOR_LOC_CD
                  INTO V_STOR_LOC_CD
                  FROM TB_INV001
                 WHERE 1=1
                   AND WERKS = V_WERKS 
                   AND MATNR = V_MATNR 
                   AND IND_BCD = V_IND_BCD;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    SELECT LGPRO
                      INTO V_STOR_LOC_CD
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = V_WERKS 
                       AND MATNR = V_MATNR;
                WHEN TOO_MANY_ROWS THEN
                    SELECT LGPRO
                      INTO V_STOR_LOC_CD
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = V_WERKS 
                       AND MATNR = V_MATNR;
            END;
                
            
            --기존 정보 존재시 수정
           UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY + V_INP_QTY
                 , PLT_QTY = PLT_QTY + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'PAL', V_INP_QTY)
                 , BOX_QTY = BOX_QTY + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BOX', V_INP_QTY)
                 , BAG_QTY = BAG_QTY + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BAG', V_INP_QTY)
                 , EA_QTY = EA_QTY + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', V_INP_QTY)
                 , ROLLCNT = ROLLCNT + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'RL', V_INP_QTY)
                 , WGT = WGT + FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'KG', V_INP_QTY)
                 , UPDDATE = SYSDATE
                 , UPDID = V_SESS_USER_ID
             WHERE 1=1
               AND WERKS = V_WERKS 
               AND MATNR = V_MATNR 
               AND STOR_LOC_CD = V_STOR_LOC_CD
               AND IND_BCD = V_IND_BCD;
            IF SQL%ROWCOUNT = 0 THEN
                --기존 자재정보 없을경우 생성
                INSERT INTO TB_INV001(WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOT_NO, MACH_CD, UNIT,
                                        STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STCK_STA, DLFL,
                                        REGDATE, REGID)
                                SELECT WERKS, V_STOR_LOC_CD, IND_BCD, MATNR, LOT_NO, V_MACH_CD, UNIT,
                                        V_INP_QTY,
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'PAL', V_INP_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'BOX', V_INP_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'BAG', V_INP_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'EA', V_INP_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'RL', V_INP_QTY),
                                        FN_CHG_UNIT(MATNR, WERKS, UNIT, 'KG', V_INP_QTY),
                                        '00', 'N', SYSDATE, V_SESS_USER_ID
                                  FROM TB_INV003
                                 WHERE 1=1
                                   AND WERKS = V_WERKS
                                   AND MACH_CD = V_MACH_CD
                                   AND MATNR = V_MATNR
                                   AND IND_BCD = V_IND_BCD;
            END IF;

            UPDATE TB_SCH019  SET              --작업지시 예외생산
                 COMP_YN          = 'N'             -- 완료여부(N:대기 I:작업중 Y:완료)         
                ,UPDDATE	      = SYSDATE         --수정일시
                ,UPDID	          = V_SESS_USER_ID  --수정자ID
            WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
            ;            


        END LOOP;

    ELSIF P_TYPE = 'SAVE4' THEN  --설비선택
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');            --설비코드
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');        --작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');     --작업지시순번  


            IF	V_MACH_CD IS  NULL OR TRIM(V_MACH_CD) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '설비코드를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

           UPDATE    TB_SCH019       
              SET --작업지시 예외생산
                 MACH_CD  = V_MACH_CD
           WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
             AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
          ;  

        END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN  --실적등록
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                    := V_OBJ.get_string('WERKS');                   --플랜트코드
            V_MACH_CD                   := V_OBJ.get_string('MACH_CD');                 --설비코드 
            V_PRFM_QTY                  := V_OBJ.get_string('PRFM_QTY');                --실적수량 
            V_PRD_STR_DT                := V_OBJ.get_string('PRD_STR_DT');              --시작일자 
            V_PRD_STR_TM                := SUBSTR(V_OBJ.get_string('PRD_STR_TM'),1,4);  --시작시간                          
            V_PRD_END_DT                := V_OBJ.get_string('PRD_END_DT');              --종료일자 
            V_PRD_END_TM                := SUBSTR(V_OBJ.get_string('PRD_END_TM'),1,4);  --종료시간                          
            V_MATNR                     := V_OBJ.get_string('MATNR');                   --품목
            V_WRK_ORDR_NO               := V_OBJ.get_string('WRK_ORDR_NO');             --작업지시번호
            V_WRK_ORDR_SEQNO            := V_OBJ.get_string('WRK_ORDR_SEQNO');          --작업지시순번  
            V_UNIT                      := V_OBJ.get_string('UNIT');                    --단위
            V_COMP_YN                   := V_OBJ.get_string('COMP_YN');                 --처리완료
            V_PRFM_UNIT                 := V_OBJ.get_string('PRFM_UNIT');               --실적단위

            IF	V_MACH_CD IS  NULL OR TRIM(V_MACH_CD) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '설비정보를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF	V_PRD_STR_DT IS  NULL OR TRIM(V_PRD_STR_DT) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '생산시작일자를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF	V_PRD_STR_TM IS  NULL OR TRIM(V_PRD_STR_TM) IS NULL   THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '생산시작시간를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF	V_PRD_END_DT IS  NULL OR TRIM(V_PRD_END_DT) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '생산종료일자를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF	V_PRD_END_TM IS  NULL OR TRIM(V_PRD_END_TM) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '생산종료시간를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF TRIM(NVL(V_COMP_YN, '')) = 'Y' THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '작업지시가 완료된 항목은 예외생산 실적을 등록할 수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            SELECT NVL(SUM(IN_QTY), 0)
              INTO V_INP_QTY
              FROM TB_INV003  --자재투입
             WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO;   

            IF	V_INP_QTY <= 0  THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '투입정보를 확인하세요';
                ROLLBACK;
                RETURN;
            END IF;
            -- 설비 정보 조회   
            SELECT MACHINE
              INTO V_MACHINE
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = V_MACH_CD;
            --작업자 정보 조회 
            SELECT WRK_CLASS
              INTO V_WRK_CLASS
              FROM USRMA
             WHERE 1=1
               AND USERID = V_SESS_USER_ID;
            --기준단위 조회
            SELECT UNIT, NVL(DSTBT_DDLIN,365*3)
              INTO V_UNIT, V_DSTBT_DAYS
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = V_WERKS
               AND MATNR = V_MATNR;
            --팔레트별 박스수량
            --V_PLTBOX := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'PLT', 'BOX',1)), 0);
            V_PLTBOX := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'PAL', 'BOX',1)), 0);
            --유통기간 확인
            V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRD_END_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            --팔레트 단위로 실적 등록
            V_CNT := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', 'PAL', V_PRFM_QTY)), 0);

            IF  V_CNT IS NULL OR V_CNT <= 0 THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '파렛트 환산정보를 학인하십시오.';
                ROLLBACK;
                RETURN;
            END IF;

            --작업지시 예외생산
            UPDATE TB_SCH019  
               SET MACH_CD          = V_MACH_CD                    --설비코드 
                 , COMP_QTY         = NVL(COMP_QTY, 0) + NVL(V_PRFM_QTY, 0)            --실적수량 
                 , COMP_YN			= 'Y' --지시 완료여부(생산종료일자 필수 입력으로 인한 지시 완료 처리)
                 , PRD_STR_DTM      = V_PRD_STR_DT||V_PRD_STR_TM   --시작일자 
                 , PRD_END_DTM      = V_PRD_END_DT||V_PRD_END_TM   --종료일자 
                 , UPDDATE = SYSDATE         --수정일시
             	 , UPDID = V_SESS_USER_ID  --수정자ID
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;            

            SELECT LOT_NO_BUF  , ORDER_NO
              INTO V_LOT_NO_BUF, V_ORDER_NO
              FROM TB_SCH019
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;  

--            --기존 LOT_NO조회
--            V_LOT_NO := V_LOT_NO_BUF ;
--            IF V_LOT_NO_BUF IS NULL OR TRIM(V_LOT_NO_BUF) IS NULL THEN
--                --Lot 확인 및 생성
--                SP_CHK_LOT_NO(V_LOT_NO_BUF, V_WERKS, V_MACH_CD, V_MATNR, V_PRD_END_DT||V_PRD_END_TM||'00', V_LOT_NO);
--
--                --작업지시 예외생산             
--                UPDATE TB_SCH019  
--                   SET LOT_NO_BUF = V_LOT_NO --LOT_NO  
--                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
--                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;            
--            END IF;
            --Lot 확인 및 생성
            SP_CHK_LOT_NO(V_LOT_NO_BUF, V_WERKS, V_MACH_CD, V_MATNR, V_PRD_END_DT||V_PRD_END_TM||'00', V_LOT_NO);

            --예외생산 작업지시에 현재 LOT_NO 저장            
            UPDATE TB_SCH019  
               SET LOT_NO_BUF = V_LOT_NO
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO; 

            --작업시간 설정
            V_STR_DATE := TO_DATE(V_PRD_STR_DT||V_PRD_STR_TM||'00', 'YYYYMMDDHH24MISS') - (INTERVAL '1' SECOND);
            V_END_DATE := TO_DATE(V_PRD_END_DT||V_PRD_END_TM||'00', 'YYYYMMDDHH24MISS') - (INTERVAL '1' SECOND);
            
            --가용수량 확인
            V_PRFM_TEMP := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', V_UNIT,V_PRFM_QTY)), 0);
            SP_REG_LOT_LOG_S01 (V_WERKS, V_MACH_CD, V_MATNR, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_TEMP, 1, V_ERR_LIST);
            IF LENGTH(V_ERR_LIST) > 0 THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := V_ERR_LIST ||' 자재 재고수량을 학인하십시오.';
                ROLLBACK;
                RETURN;
            END IF;
            
            FOR I IN 0..V_CNT - 1 LOOP
                --개별바코드
                SP_GET_BARCODE_SEQ('IND', V_WERKS, V_MACH_CD, V_MATNR, V_PRD_END_DT||V_PRD_END_TM||'00', V_IND_BCD);
                --문서번호 생성
                V_DOC_NO := FN_GET_MDOCNO('M', 'IF141');
                V_DOC_SEQNO := 1 ;
               
               --팔레트 단위로 수량 분할
               IF V_PRFM_QTY >= V_PLTBOX THEN
                	--개별 팔레트별 박스수량
                	V_IND_QTY := V_PLTBOX;
                	V_CONF := '';
               ELSE 
               		V_IND_QTY := V_PRFM_QTY;
              		--마지막 팔레트의 경우 완료처리
               		V_CONF := 'X';
               END IF;
               
                --박스 잔량 계산
                V_PRFM_QTY := V_PRFM_QTY - V_PLTBOX;
                V_PRFM_QTY := CASE WHEN V_PRFM_QTY < 0 THEN 0 ELSE V_PRFM_QTY END;
                --단위별 환산
                V_PRFM_TEMP := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', V_UNIT,V_IND_QTY)), 0);
                V_PRFM_PLT := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', 'PAL',V_IND_QTY)), 0);
                V_PRFM_BOX := V_IND_QTY ;
                V_PRFM_BAG := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', 'BAG',V_IND_QTY)), 0);
                V_PRFM_EA := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', 'EA',V_IND_QTY)), 0);
                V_PRFM_KG := NVL(CEIL(FN_CHG_UNIT(V_MATNR, V_WERKS, 'BOX', 'KG',V_IND_QTY)), 0);
                --마지막 실적 여부 확인
                --V_COMP := CASE WHEN V_CNT = 0 THEN 'Y' ELSE 'N' END;
                V_COMP := CASE WHEN V_CONF = 'X' THEN 'Y' ELSE 'N' END;
                --실적당 시간 처리
                V_STR_DATE := V_STR_DATE; --첫팔레트 시작시간
                --V_STR_DATE := V_STR_DATE + (INTERVAL '1' SECOND);
                V_END_DATE := V_END_DATE + (INTERVAL '1' SECOND);
                
                V_DATE := SYSDATE;
                --HL 생산실적 등록
                INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                        ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        PRFM_QTY, UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT,
                                        PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS,
                                        PRD_STR_DATE, PRD_END_DATE,
                                        STA, COMP_YN, --CHK_PP_YN, CHK_PP_DATE, CHK_PP_ID,
                                        DOC_NO, DOC_SEQNO, REGDATE, REGID)
                               VALUES(V_WERKS, V_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,
                                        V_ORDER_NO, V_WRK_ORDR_NO,V_WRK_ORDR_SEQNO,
                                        V_PRFM_TEMP, V_UNIT, V_PRFM_PLT, V_PRFM_BOX, V_PRFM_BAG, V_PRFM_EA, V_PRFM_KG,
                                        V_PRD_END_DT, V_PRD_END_DT, V_DSTBT_DDLIN, V_WRK_CLASS,
                                        V_STR_DATE, V_END_DATE, 
                                        '01', V_COMP, --'Y', V_DATE, V_SESS_USER_ID,
                                        V_DOC_NO, V_DOC_SEQNO, V_DATE, V_SESS_USER_ID);
                --실적수량 재고등록
                INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                        MATNR, LOT_NO, IND_BCD, UNIT, MACH_CD, MACHINE,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                        PRD_DT, PRFM_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, STCK_STA,
                                        DLFL, REGDATE, REGID)
                                VALUES(V_WERKS, '3100',
                                        V_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT, V_MACH_CD, V_MACHINE,
                                        V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO,
                                        V_PRD_END_DT, V_PRD_END_DT, V_PRFM_TEMP, V_PRFM_PLT, V_PRFM_BOX, V_PRFM_BAG, V_PRFM_EA, '00',
                                        'N', V_DATE, V_SESS_USER_ID);

                --자재 소요량 SAP전송 문서번호 반환
                SP_REG_LOT_LOG_I01 (V_WERKS, V_MACH_CD, V_MATNR, V_LOT_NO, V_IND_BCD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_END_DT, V_PRFM_TEMP, V_UNIT, 'N', 1, V_SESS_USER_ID, P_CODE, P_MSG);
                IF P_CODE = 'E' THEN
                    ROLLBACK;
                    RETURN;
                END IF;

                --인터페이스(화장지:P200, 기저귀:P500) 생리대의 경우 완제품입고 요청시 테이블에 추가됨
                IF V_WERKS = 'P200' OR V_WERKS = 'P500' THEN

                    INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                                            PROQTY, MEINS, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                                            MDOCNO, MDOCSEQ, CONF, MAKE_DATE, MAKER)
                                    VALUES(V_ORDER_NO, V_LOT_NO, V_WERKS, V_PRD_END_DT /*(||V_PRD_END_TM||V_TM_SEC*/, V_MATNR, 
                                            V_PRFM_TEMP, V_UNIT, 0, V_SESS_USER_ID,
                                            TO_CHAR(V_STR_DATE,'YYYYMMDD'), TO_CHAR(V_STR_DATE,'HH24MISS'), 
                                            TO_CHAR(V_END_DATE,'YYYYMMDD'), TO_CHAR(V_END_DATE,'HH24MISS'),
                                            V_DOC_NO, V_DOC_SEQNO, V_CONF, SYSDATE, V_SESS_USER_ID);
                    --문서번호 반환
                    IF P_DOC_NO IS NULL THEN
                        P_DOC_NO := V_DOC_NO;
                    ELSE
                        P_DOC_NO := P_DOC_NO || ',' || V_DOC_NO;
                    END IF;
                END IF;
                --현재 팔레트 완료시간을 다음 팔레트의 시작시간으로 등록
                V_STR_DATE := V_END_DATE;
            END LOOP;

        END LOOP;
                    
--        --작업지시 예외생산
--        UPDATE TB_SCH019  
--           SET COMP_YN = DECODE(V_COMP,'Y','Y','I') --완료여부(N:대기 I:작업중 Y:완료)         
--             ,UPDDATE = SYSDATE         --수정일시
--             ,UPDID = V_SESS_USER_ID  --수정자ID
--         WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
--           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;            
    END IF;

    P_SUCCESS := 'Y';
    P_CODE := 'S';

    --ROLLBACK ;
    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;

/
