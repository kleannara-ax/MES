
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK34_S02" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS        OUT    varchar2,
    P_CODE           OUT    VARCHAR2 ,
    P_MSG            OUT    VARCHAR2 ,
	P_RS_LIST        OUT    SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_WRK34_S02{호출 프로그램 ID 기술}
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK34_S02';     -- PROCEDURE NAME

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
   V_LOT_NO         TB_INV001.LOT_NO%TYPE;              --LOT_NO
   V_MATNR_1        TB_SCH019.MATNR%TYPE;               --품명
   V_LOT_NO_BUF     TB_SCH019.LOT_NO_BUF%TYPE;          --LOT NO BUF
   V_ORDER_NO       TB_SCH019.ORDER_NO%TYPE;            --오더번호

   V_DOC_NO         VARCHAR2(20);
   V_DOC_SEQNO      NUMBER;
   V_RUECK	        VARCHAR2(10 BYTE);	                --SAP 확정번호
   V_RMZHL	        VARCHAR2(8 BYTE);	                --SAP 확정카운터    

   V_STOR_LOC_CD    TB_INV001.STOR_LOC_CD%TYPE;  --저장위치
   V_STCK_STA       TB_INV001.STCK_STA%TYPE;     --재고상태

   V_NUM            NUMBER;   

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
   V_WERKS          	  :=       V_JSON.get_string('WERKS');	         --플랜트    
   V_MATNR                :=       V_JSON.get_string('MATNR');           --자재코드

   V_WRK_ORDR_NO          :=       V_JSON.get_string('WRK_ORDR_NO');     --작업지시번호
   V_WRK_ORDR_SEQNO       :=       V_JSON.get_string('WRK_ORDR_SEQNO');  --작업지시순번
   V_MACH_CD              :=       V_JSON.get_string('MACH_CD');         --설비코드

   IF P_TYPE = 'LIST' THEN  /* POP UP 조회 리스트*/

        V_SQL := '      SELECT INV001.MATNR                 MATNR           --자재
                             , MAS001.MATNR_NM              MATNR_NM        --자재명
                             , INV001.STOR_LOC_CD	        STOR_LOC_CD     --저장위치
                             , MAS003.STOR_LOC_NM	        STOR_LOC_NM     --저장위치명
							 , INV001.LOT_NO				LOT_NO			--LOT_NO
                             , INV001.IND_BCD	            IND_BCD         --개별바코드
                             , INV001.UNIT                  UNIT            --단위
                             , INV001.STCK_QTY        	    STCK_QTY        --재고수량
                             , NULL                         INP_QTY_TOT     --투입수량합계
                             , 0                            INP_QTY         --투입수량   
                             , INV001.WERKS                 WERKS
                             , INV001.STCK_STA              STCK_STA        --재고상태
                          FROM TB_INV001  INV001     --창고별 재고현황
                             , TB_MAS003  MAS003     --저장위치 마스터(공정창고내 저장위치 포함)
                             , TB_MAS001  MAS001     --플랜트별 제품/자재 마스터
                         WHERE  1 = 1
                           AND INV001.WERKS         = MAS003.WERKS(+)  
                           AND INV001.STOR_LOC_CD   = MAS003.STOR_LOC_CD(+) 
                           AND INV001.MATNR         = MAS001.MATNR(+) 
                           AND INV001.WERKS         = MAS001.WERKS(+) 
                            ';        
		V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''' ; 	--플랜트
		V_SQL := V_SQL || ' AND INV001.MATNR  = ''' || V_MATNR || '''' ; 	   --자재코드
        V_SQL := V_SQL || ' AND NVL(INV001.STCK_QTY, 0)  > 0 ' ; 	   --자재코드 
        V_SQL := V_SQL || ' AND INV001.STOR_LOC_CD NOT IN (''2010'', ''2020'', ''3100'') ';
        V_SQL := V_SQL || ' AND NVL(INV001.STCK_STA, ''00'') != ''40'' ';

        V_SQL := V_SQL || ' ORDER BY NVL(INV001.STCK_QTY, 0) DESC' ; 	  

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SAVE' THEN  --공정투입
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	                    := V_OBJ.get_string('WERKS');              --플랜트코드
            V_MATNR                     := V_OBJ.get_string('MATNR');              --자재코드
            V_LOT_NO                    := V_OBJ.get_string('LOT_NO');             --자재 LOT_NO
            V_IND_BCD                   := V_OBJ.get_string('IND_BCD');            --업체/개별 바코드
            V_INP_QTY                   := V_OBJ.get_string('INP_QTY');            --투입수량
            V_UNIT                      := V_OBJ.get_string('UNIT');               --단위
            V_STOR_LOC_CD	            := V_OBJ.get_string('STOR_LOC_CD');        --저장위치

            IF	V_MACH_CD IS  NULL OR TRIM(V_MACH_CD) IS NULL THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '설비코드를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            IF	NVL(V_INP_QTY, 0) = 0      THEN
                P_CODE    := 'E';
                P_SUCCESS := 'N';
                P_MSG     := '투입량을 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

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
              --AND IND_BCD   = V_IND_BCD
            ;   

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

           UPDATE TB_INV001 
              SET STCK_QTY  =  STCK_QTY - V_INP_QTY,
                  UPDDATE = SYSDATE,
                  UPDID = V_SESS_USER_ID
            WHERE WERKS        =  V_WERKS
              AND STOR_LOC_CD  =  V_STOR_LOC_CD 
              AND IND_BCD      =  V_IND_BCD 
              AND MATNR        =  V_MATNR
           ;   

       END LOOP;

    END IF;

    P_SUCCESS := 'Y';
    P_CODE := 'S';

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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;
/
