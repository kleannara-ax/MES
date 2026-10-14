--------------------------------------------------------
--  DDL for Procedure SP_INV11_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV11_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_MSG           OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR,
    P_DOC_NO        OUT    varchar2 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV11_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 완제품 불출요청(PS) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 완제품 불출요청(PS) 를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2023/01/11 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/11    1.0.0   여한진         Initial Version
 *==============================================================================
 *  관련 테이블
 *        - [V_WRK_ORDR] : (.R..) 작업지시 뷰
 * 		  - [TB_SCH020] : (.R..) 작업지시 BOM정보
 * 		  - [TB_MAS001] : (.R..) 자재마스터
 * 		  - [TB_MAS005] : (.R..) 자재 단위환산마스터
 * 		  - [TB_SCH019] : (.R..) 예외 작업지시
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV11_S01';     -- PROCEDURE NAME


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
    V_OBJ2			 JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);

   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
    V_OUT_SQL      	 CLOB;
    V_DOC_SQL   	 varchar2(1000);


    V_DEBUG          varchar2(1);
	V_LEN			NUMBER;
   
    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS			TB_SCH008.WERKS%TYPE;		--플랜트
    V_MACHINE       TB_SCH008.MACHINE%TYPE;     --생산호기 

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_ORDER_NO	           TB_SCH019.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH013.WRK_ORDR_QTY%TYPE;       --지시수량
    V_WRK_SEQNO            TB_SCH013.WRK_SEQNO%TYPE;          --작업순서    
    V_ORDR_GEN_DT	       TB_SCH013.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH013.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH013.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH013.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH013.COMP_YN%TYPE;            --확정여부 

    V_MATNR	               TB_SCH020.MATNR%TYPE;                      --하위자재코드
    V_STOR_LOC_CD          TB_SCH020.STOR_LOC_CD%TYPE;                --저장위치

    V_STCK_QTY             TB_INV001.STCK_QTY%TYPE;                   --재고수량
    V_MES_STCK_QTY         TB_INV001.STCK_QTY%TYPE;                   --MES재고

    V_ORDER_BOM_QTY        TB_SCH020.ORDER_BOM_QTY%TYPE;              --소요량
    V_UNIT                 TB_SCH020.UNIT%TYPE;                       --기본단위
    V_REQ_QTY              TB_INV002.QTY%TYPE;                        --요청수량
    V_DOC_NO               TB_IFRWM002.DOC_NO%TYPE;                   --MES 문서번호
    V_DOC_SEQ              TB_SCH020.DOC_SEQ%TYPE;                    --MES 문서순번
    V_DLFL                 TB_INV002.DLFL%TYPE;                       --삭제여부
    V_QTY                  TB_INV002.QTY%TYPE;                        --불출요청량
    V_WMS_STCK_QTY         TB_INV002.QTY%TYPE;                        --WMS창고재고수량        

    V_IF_STA               TB_INV002.IF_STA%TYPE;                     --WMS 결과값     
    V_WRK_ORDR_NO	       TB_SCH019.WRK_ORDR_NO%TYPE;                --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_SCH019.WRK_ORDR_SEQNO%TYPE;             --작업지시순번

    V_IF_MES_ID            TB_IFRWM002.IF_MES_ID%TYPE;                --MES Interface ID
    V_SEQ                  NUMBER(5)    ;                             --MES 문서순번(번호)
    V_DOC_NO_1             VARCHAR2(4000);
    V_MATNR_DIV            TB_MAS001.MATNR_DIV%TYPE;
    V_LOT_NO               TB_INV001.LOT_NO%TYPE;                     --LOT_NO
    V_CON_TYPE             TB_INV001.CON_TYPE%TYPE;                   --컨테이너유형
    V_VBELN                TB_INV001.VBELN%TYPE;                      --판매문서
    V_POSNR                TB_INV002.OPOSNR%TYPE;                     --판매문서 항목번호
    V_KUNNR                TB_INV001.KUNNR%TYPE;                      --거래처코드
    V_NTN_CD               TB_INV002.NTN_CD%TYPE;                     --국가코드
    V_STRGR                TB_MAS001.STRGR%TYPE;                      --생산전략
    V_SKNUM					TB_INV002.SKNUM%TYPE;					--선적번호
    V_DELIPOT				TB_SCH019.DELIPOT%TYPE;					--하역지점
    V_WRK_ORDR				TB_SCH019.WRK_ORDR_NO%TYPE;
    V_ORDER_SEQNO			TB_SCH019.WRK_SEQNO%TYPE;				--오더순번
   
    V_INOUT_GU             VARCHAR2(2); 
    V_PROC_CD              VARCHAR2(20); 
    WRK_ORDR_CUR			SYS_REFCURSOR;
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'Y';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_WERKS          	:=       V_JSON.get_string('WERKS');	    --플랜트
   V_MACHINE            :=       V_JSON.get_string('MACHINE');      --생산호기
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번
   V_INOUT_GU 		    :=       V_JSON.get_string('INOUT_GU');   	--불출구분  'E'  , 'N' , ''
   -- 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가
   V_OUT_SQL			:=		V_JSON.get_string('OUT_SQL');
   V_PROC_CD            :=		V_JSON.get_string('PROC_CD');


	IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
		V_SQL :=  ' SELECT
                       WRK_ORDR.WERKS       		 WERKS            		--플랜트
	                 , WRK_ORDR.WRK_ORDR_NO 		 WRK_ORDR_NO			--작업지시번호
	                 , WRK_ORDR.WRK_ORDR_SEQNO 	     WRK_ORDR_SEQNO			--작업지시순번
					 , WRK_ORDR.WRK_SEQNO			 WRK_SEQNO				--작업순서
	                 , WRK_ORDR.ORDR_QTY  	         WRK_ORDR_QTY   		--지시량
	                 , WRK_ORDR.MACHINE      		 MACHINE		 	    --생산 호기
	                 , WRK_ORDR.PRD_REQ_DT		     PRD_REQ_DT			    --생산요청일자
	                 , WRK_ORDR.ORDER_NO     		 ORDER_NO			    --오더번호
	                 , WRK_ORDR.ORDER_SEQNO  		 ORDER_SEQNO	   	    --순번
					 , REGEXP_REPLACE(WRK_ORDR.ORDER_DIV_NM, ''제지 | 오더 유형'', '''')	ORDER_DIV		--오더유형
	                 , WRK_ORDR.MATNR       		 MATNR					--자재코드
	                 , WRK_ORDR.MATNR_NM	         MATNR_NM  			    --자재명
	                 , WRK_ORDR.FQTY	  		     FQTY					--오더량
	                 , WRK_ORDR.UNIT		  		 UNIT					--단위
	                 , WRK_ORDR.WRK_ORDR_REMARK      WRK_ORDR_REMARK		--작업지시비고
					 , DECODE(SUBSTR(WRK_ORDR.WRK_ORDR_NO, 3, 2), ''EX'', SUBSTR(SCH020.MATNR, 10, 4) || ''*'' || SUBSTR(SCH020.MATNR, 14, 4), NULL) PRE_CHG_SPEC	--변경 전 규격
					 , DECODE(SUBSTR(WRK_ORDR.WRK_ORDR_NO, 3, 2), ''EX'', SUBSTR(WRK_ORDR.MATNR, 10, 4) || ''*'' || SUBSTR(WRK_ORDR.MATNR, 14, 4), NULL) AFTER_CHG_SPEC	--변경 후 규격	
					 , FN_CD_VAL(''DELIPOT'', WRK_ORDR.DELIPOT)				DELIPOT					--하역지점
	                 , WRK_ORDR.REGDATE            REGDATE				--등록일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = WRK_ORDR.REGID),WRK_ORDR.REGID)	             REGNM					--등록자
	                 , WRK_ORDR.UPDDATE            UPDDATE				--수정일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = WRK_ORDR.UPDID),WRK_ORDR.UPDID)				 UPDNM					--수정자
                FROM V_WRK_ORDR WRK_ORDR
					,TB_SCH020 SCH020
					,TB_MAS001 M001
               WHERE 1=1
				 AND WRK_ORDR.ORDER_NO = SCH020.ORDER_NO(+)
				 AND SCH020.WERKS = M001.WERKS(+)
				 AND SCH020.MATNR = M001.MATNR(+)
                 AND NVL(SCH020.DLFL, ''N'') = ''N''
				 AND M001.MATNR_DIV IN(''HALB'', ''FERT'', ''HAWA'')
				 AND NVL(WRK_ORDR.COMP_YN, ''N'') <> ''Y'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND WRK_ORDR.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;
       
        --20221019 여한진 화장지 같은 경우 생산호기가 합지랑 가공이 구분이 가지 않아서 공정코드로 구분하기 위해
        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN                                 --생산호기
            V_SQL := V_SQL || ' AND WRK_ORDR.MACHINE = ''' || V_MACHINE || '''';	   
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드(WRK_ORDR.MATNR) ,생산요청일자(WRK_ORDR.PRD_REQ_DT)
        END IF; 

        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
            V_SQL := V_SQL || ' AND WRK_ORDR.PROC_CD = ''' || V_PROC_CD || '''';			   --공정
        END IF;

        IF    V_INOUT_GU = 'E' THEN
            V_SQL := V_SQL ||' AND WRK_ORDR.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
        ELSIF V_INOUT_GU = 'N' THEN
            V_SQL := V_SQL ||' AND WRK_ORDR.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
        END IF;

        V_SQL := V_SQL || ' ORDER BY WRK_ORDR.WERKS ASC, WRK_ORDR.ORDER_NO ASC ,WRK_ORDR.WRK_ORDR_NO ASC,WRK_ORDR.WRK_ORDR_SEQNO ASC';  

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
 	V_SQL :=  ' SELECT 
	                     SCH020.WERKS       		                               	
						,SCH020.ORDER_NO
						,SCH019.WRK_SEQNO					ORDER_SEQNO							
	                    ,SCH020.MATNR	                                            
	                    ,MAS001.MATNR_NM		                                    
						,MAS001.MATNR_DIV											
						,MAS001.LGFSB												
	                    ,SCH020.STOR_LOC_CD                                         
	                    ,MAS003.STOR_LOC_NM                                         
	                    ,SCH020.LOT_NO                                              
	                    ,NVL((SELECT SUM(INV001.STCK_QTY)
	                        FROM TB_INV001  INV001
	                       WHERE INV001.WERKS = SCH020.WERKS
	                         AND INV001.MATNR = SCH020.MATNR
							 AND INV001.LOT_NO = SCH020.LOT_NO 
	                      ), 0)                         	MES_STCK_QTY                    
	                    ,(   SELECT  SUM(A.USEQTY)		
	                           FROM V_WMS_STKKY@KNRAWMSLINK A
	                          WHERE A.LOTA02 = SCH020.WERKS
	                            AND A.SKUkey = SCH020.MATNR
								AND A.LOTA15 = SCH020.LOT_NO
	                     )                              	WMS_STCK_QTY                                
	                    ,SCH020.ORDER_BOM_QTY                                  
	                    --,CEIL(FN_CHG_UNIT(SCH020.MATNR, SCH020.WERKS, SCH020.UNIT, ''PAL'', SCH020.ORDER_BOM_QTY))   PLT_QTY                      --PLT
	                    --,CEIL(FN_CHG_UNIT(SCH020.MATNR, SCH020.WERKS, SCH020.UNIT, ''BOX'', SCH020.ORDER_BOM_QTY)) BOX_QTY                    --BOX
	                    --,CEIL(FN_CHG_UNIT(SCH020.MATNR, SCH020.WERKS, SCH020.UNIT, ''M'', SCH020.ORDER_BOM_QTY)) M                        --M
	                    ,DECODE(SCH020.UNIT, ''KG'', SCH020.ORDER_BOM_QTY
												   , ''R'', (SCH020.ORDER_BOM_QTY * 500) * (MAS001.BS_WGT/1000) * (MAS001.WLEN/1000) * (MAS001.VLEN/1000)
												   , SCH020.ORDER_BOM_QTY * (MAS001.BS_WGT/1000) * (MAS001.WLEN/1000) * (MAS001.VLEN/1000))   KG
	                    --,CEIL(FN_CHG_UNIT(SCH020.MATNR, SCH020.WERKS, SCH020.UNIT, ''RL'', SCH020.ORDER_BOM_QTY)) RL                        --RL
						,SCH020.UNIT
						,SCH020.ORDER_BOM_QTY 			REQ_QTY                    
					FROM TB_SCH020    SCH020  --작업지시 BOM
						,TB_SCH019	  SCH019	--예외작업지시
	                   , TB_MAS001    MAS001  --플랜트별 제품/자재 마스터
	                   , TB_MAS003    MAS003  --저장위치 마스터(공정창고내 저장위치 포함)
	                   --, TB_MAS005    MAS005  --자재별 단위 환산 마스터(PAL) 
	                   --, TB_MAS005    MAS0051 --자재별 단위 환산 마스터(BOX) 
	                   --, TB_MAS005    MAS0052 --자재별 단위 환산 마스터(M) 
	                   , TB_MAS005    MAS0053 --자재별 단위 환산 마스터(KG) 
	                   --, TB_MAS005    MAS0054 --자재별 단위 환산 마스터(RL) 
	               WHERE SCH020.MATNR   = MAS001.MATNR(+)
	                 AND SCH020.WERKS   = MAS001.WERKS(+) 
	                 AND SCH020.WERKS       = MAS003.WERKS(+)
	                 AND SCH020.STOR_LOC_CD = MAS003.STOR_LOC_CD(+)
					 AND SCH020.ORDER_NO = SCH019.ORDER_NO
	                 --AND SCH020.MATNR   = MAS005.MATNR(+)
	                 --AND MAS005.UNIT(+) = ''PAL'' 
	                 --AND SCH020.MATNR   = MAS0051.MATNR(+)
	                 --AND MAS0051.UNIT(+) = ''BOX'' 
	                 --AND SCH020.MATNR   = MAS0052.MATNR(+)
	                 --AND MAS0052.UNIT(+) = ''M'' 
	                 AND SCH020.MATNR   = MAS0053.MATNR(+)
	                 AND MAS0053.UNIT(+) = ''KG'' 
	                 --AND SCH020.MATNR   = MAS0054.MATNR(+)
	                 --AND MAS0054.UNIT(+) = ''RL'' 
	                 AND NVL(SCH020.ORDER_BOM_QTY, 0.0) > 0
                     AND NVL(SCH020.DLFL, ''N'') = ''N''
					 ';
		/* 2022-05-10(화요일)-안상현, 하위 쿼리 조건 추가 */
        --IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
        --    V_SQL := V_SQL || ' AND SCH020.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        --END IF;

        IF  V_OUT_SQL IS NOT NULL OR TRIM(V_OUT_SQL) != '' THEN
            V_SQL := V_SQL || V_OUT_SQL ;			                       	               -- ('11',21) , ('11',21)
        END IF;

        V_SQL := V_SQL || ' ORDER BY SCH020.ORDER_NO, SCH020.MATNR';  

        /*IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;*/

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN
        V_ARR_LIST        := V_JSON.get_array('list');
        V_DOC_SQL := '';
        V_SEQ     := 0 ;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_WERKS	         := V_OBJ.get_string('WERKS');                --플랜트
            V_ORDER_NO	     := V_OBJ.get_string('ORDER_NO');			  --오더번호
            V_ORDER_SEQNO	 := V_OBJ.get_string('ORDER_SEQNO');		  --오더순번
            V_MATNR	         := V_OBJ.get_string('MATNR');                --하위자재코드
            V_STOR_LOC_CD    := V_OBJ.get_string('STOR_LOC_CD');          --저장위치

            --V_STCK_QTY       := V_OBJ.get_string('STCK_QTY');             --재고수량
            V_MES_STCK_QTY	 := V_OBJ.get_string('MES_STCK_QTY');         --MES재고

            V_ORDER_BOM_QTY  := V_OBJ.get_string('ORDER_BOM_QTY');        --소요량
            V_UNIT           := V_OBJ.get_string('UNIT');                 --기본단위
            V_REQ_QTY        := V_OBJ.get_string('REQ_QTY');              --요청수량
            --V_DOC_NO         := V_OBJ.get_string('DOC_NO');               --MES 문서번호
            --V_DOC_SEQ        := V_OBJ.get_string('DOC_SEQ');              --MES 문서순번
            V_DLFL           := V_OBJ.get_string('DLFL');                 --삭제여부
            --V_WMS_STCK_QTY     := V_OBJ.get_string('WMS_STCK_QTY');       --창고재고수량
            V_LOT_NO         := V_OBJ.get_string('LOT_NO');             --LOTNO
            V_DELIPOT		:=	V_JSON.get_string('DELIPOT');		--하역지점

            V_IF_STA := 'N' ;

            SELECT  NVL(SUM(A.USEQTY), 0)
              INTO V_WMS_STCK_QTY
              FROM V_WMS_STKKY@KNRAWMSLINK A
             WHERE A.LOTA02  = V_WERKS
               AND A.SKUkey    = V_MATNR;
              
            IF V_WMS_STCK_QTY  < NVL(V_REQ_QTY, 0)  THEN
				P_SUCCESS      := 'N';
				P_MSG       := 'WMS 재고가 부족 합니다.';
				ROLLBACK;
				RETURN;
            END IF;  

            IF  V_REQ_QTY  > 0  THEN
                V_IF_MES_ID := 'MES_IF_201' ;
                SELECT FN_GET_MDOCNO('M', 'IF201')  INTO V_DOC_NO  FROM DUAL ;   --MES 문서번호

                IF NVL(V_DOC_NO_1, ' ') = ' ' THEN
                    V_DOC_NO_1 := V_DOC_NO;
                ELSE
                    V_DOC_NO_1 := V_DOC_NO_1 || ',' || V_DOC_NO;
                END IF;
				
               	V_SKNUM := SUBSTR(V_DOC_NO, -10);		--선적번호(MES 문서번호 뒤에서 10자리)
               
                --PS- 제품, 상품, 반제품은  저장위치 2000으로 요청
                --IF V_WERKS <> 'P100' THEN
                    SELECT MATNR_DIV INTO V_MATNR_DIV
                      FROM TB_MAS001
                     WHERE WERKS = V_WERKS
                       AND MATNR = V_MATNR;

                    IF V_MATNR_DIV IN ('FERT', 'HALB', 'HAWA') THEN
                        V_STOR_LOC_CD := '2000';
                    END IF;
                --END IF;

                V_DLFL    := 'C' ;                 
                V_SEQ     := 1 ;

               --20220902 여한진
               --PS완제품 불출요청시 LOT_NO, 국가코드, 판매문서MTO, 컨테이너유형 데이터 필요
               --MTO/MTS 구분
                /*BEGIN
                SELECT STRGR INTO V_STRGR 
                  FROM TB_MAS001
                 WHERE WERKS = V_WERKS
                   AND MATNR = V_MATNR;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_STRGR := '00';
                END;

                IF V_STRGR = '20' OR V_STRGR = '50' THEN    --MTO
                    IF NVL(V_LOT_NO, ' ') <> ' ' THEN
                    	BEGIN
	                       	SELECT DISTINCT
	                               CON_TYPE, LPAD(VBELN,10,'0'), LPAD(POSNR,6,'0'), KUNNR
	                          INTO V_CON_TYPE, V_VBELN, V_POSNR, V_KUNNR
	                          FROM TB_INV001
	                         WHERE LOT_NO = V_LOT_NO
	                           AND NVL(DLFL, 'N') IN ('N', 'A');
						EXCEPTION 
							WHEN NO_DATA_FOUND THEN
								P_SUCCESS	:= 'N';
			                    P_MSG       := '해당 ' || V_LOT_NO || '의 정보가 없습니다.';
			                    ROLLBACK;
			                    RETURN;
						END;
						
                       	IF NVL(V_KUNNR, ' ') <> ' ' THEN
                           SELECT LAND1 INTO V_NTN_CD
                             FROM TB_MAS009
                            WHERE CUST_CD = V_KUNNR
                              AND CUST_DIV = 'C';
                       END IF;
                    END IF;
                ELSE                                        --MTS
                    V_VBELN := '';
                    V_POSNR := '';
                    V_KUNNR :='';
                END IF;*/
                
                --임시 사용(테스트용)
                V_VBELN := '';
                V_POSNR := '';
                V_KUNNR := '';
                    
               INSERT INTO TB_INV002 
               (
                         DOC_NO	                        --MES 문서번호
                        ,DOC_SEQ	                    --MES 문서순번
                        ,DLFL	                        --삭제 지시자(불출요청)
                        ,REQ_DIV	                    --요청구분
                        ,WERKS	                        --플랜트
                        ,MATNR	                        --품목코드
                        ,QTY	                        --불출요청량
                        ,UNIT	                        --단위
                        ,STOR_LOC_CD	                --저장위치(공정창고)
                        ,STOR_LOC_TO	                --저장위치(WMS창고)
                        ,STCK_STA	                    --재고상태 (00정상 30불용 05품질 50폐기 10보류)
                        ,ORDER_NO		                --오더번호
                        ,ORDER_SEQNO	                --오더순번
                        ,STCK_KY	
                        ,LOT_NUM	
                        ,NTN_CD	                        --국가코드
                        ,CRSPD_CD	                    --거래처코드MTO
                        ,PRDC_DT	                    --제조일자
                        ,RCVGDS_DT	                    --입고일자
                        ,DSTBT_DDLIN	                --유통기한 (생리대,기저귀,물티슈)
                        ,IND_BCD	                    --개별바코드 (협력업체바코드)
                        ,LOT_NO	                        --LOT번호/SAP 배치번호
                        ,OVBELN	                        --주문번호
                        ,OPOSNR	                        --주문번호 항목번호
                        ,IF_STA	                        --WMS 결과값 Return( N:요청, Y:완료 )
                        ,SKNUM							--선적번호
                        ,DELIPOT 						--하역지점
                        ,REGDATE	                    --등록일시
                        ,REGID	                        --등록자ID
                        ,UPDDATE	                    --수정일시
                        ,UPDID	                        --수정자ID               
               ) VALUES (
                         V_DOC_NO	                            --MES 문서번호
                        ,TO_CHAR(V_SEQ)	                        --MES 문서순번
                        ,V_DLFL	                                --삭제 지시자(불출요청)
                        ,'10'	                                --요청구분
                        ,V_WERKS	                            --플랜트
                        ,V_MATNR	                            --품목코드
                        ,V_REQ_QTY                              --불출요청량
                        ,V_UNIT	                                --단위
                        ,NULL	                                --저장위치(공정창고)
                        ,V_STOR_LOC_CD	                        --저장위치(WMS창고)
                        ,'00'	                                --재고상태 (00정상 30불용 05품질 50폐기 10보류)
                        ,V_ORDER_NO                             --오더번호
                    	,LTRIM(V_ORDER_SEQNO, '0')            --오더순번
                        ,NULL	
                        ,NULL	
                        ,V_NTN_CD                               --국가코드
                        ,V_KUNNR                                --거래처코드MTO
                        ,NULL	                                --제조일자
                        ,NULL	                                --입고일자
                        ,NULL	                                --유통기한 (생리대,기저귀,물티슈)
                        ,NULL	                                --개별바코드 (협력업체바코드)
                        ,V_LOT_NO                               --LOT번호/SAP 배치번호
                        ,V_VBELN                                --주문번호
                        ,V_POSNR                                --주문번호 항목번호
                        ,'N'	                                --WMS 결과값 Return( N:요청, Y:완료 )
                        ,V_SKNUM								--선적번호
                        ,V_DELIPOT								--하역지점
                        ,SYSDATE	    	                    --등록일시
                        ,V_SESS_USER_ID	                        --등록자ID
                        ,SYSDATE		                        --수정일시
                        ,V_SESS_USER_ID	                        --수정자ID
               );

               --자재 및 완제품 불출요청으로 통보(MES -> WMS)
               INSERT INTO   TB_IFSWM002 
               (
                         DOC_NO	        --MES 문서번호
                        ,DOC_SEQNO	    --MES 문서순번
                        ,DLFL	        --삭제 지시자(불출요청)
                        ,WERKS	        --플랜트
                        ,MATNR	        --품목코드
                        ,QTY	        --불출요청량
                        ,UNIT	        --단위
                        ,STOR_LOC	    --저장위치(공정창고)
                        ,ORDER_NO	    --오더번호(생산작업지시번호)
                        ,ORDER_SEQNO	--오더번호 순번(생산작업지시순번)
                        ,STCK_STA    	--재고상태 (00정상 30불용 05품질 50폐기 10보류)
                        ,NTN_CD	        --국가코드
                        ,CRSPD_CD	    --거래처코드MTO
                        ,PRDC_DT	    --제조일자
                        ,RCVGDS_DT	    --입고일자
                        ,DSTBT_DDLIN	--유통기한 (생리대,기저귀,물티슈)
                        ,IND_BCD	    --개별바코드 (협력업체바코드)
                        ,LOT_NO	        --LOT번호/SAP 배치번호
                        ,OVBELN	        --주문번호
                        ,OPOSNR	        --주문번호 항목번호
                        ,CON_TYPE       --컨테이너 유형(PS)
                        ,IF_STATUS	    --WMS 결과값 Return( S:성공, E:오류 )
                        ,IF_GET_DATE	--MES 등록일시
                        ,IF_SET_DATE	--WMS 전송일시
                        ,IF_ERR_MESS	--WMS 결과 메시지
                        ,IF_MES_KEY	    --MES Inserface Key(MES->WMS)
                        ,REQ_DTM	    --출고요청일시
                        ,REQ_EXE_DT	    --출고예정일자
                        ,SKNUM			--선적번호     
                        ,DELIPOT		--하역지점                  
               ) VALUES (
                         V_DOC_NO	        --MES 문서번호
                        ,TO_CHAR(V_SEQ)	    --MES 문서순번
                        ,'C'	            --삭제 지시자(불출요청)
                        ,V_WERKS	        --플랜트
                        ,V_MATNR	        --품목코드
                        ,V_REQ_QTY	        --불출요청량
                        ,V_UNIT	            --단위
                        ,V_STOR_LOC_CD	    --저장위치(공정창고)
                        ,V_ORDER_NO         --오더번호(생산작업지시번호)
                        ,LTRIM(V_ORDER_SEQNO, '0')      --오더번호 순번(생산작업지시순번)
                        ,'00'    	        --재고상태 (00정상 30불용 05품질 50폐기 10보류)
                        ,V_NTN_CD           --국가코드
                        ,V_KUNNR            --거래처코드MTO
                        ,NULL	            --제조일자
                        ,NULL	            --입고일자
                        ,NULL	            --유통기한 (생리대,기저귀,물티슈)
                        ,NULL	            --개별바코드 (협력업체바코드)
                        ,V_LOT_NO           --LOT번호/SAP 배치번호
                        ,V_VBELN            --주문번호
                        ,V_POSNR            --주문번호 항목번호
                        ,V_CON_TYPE         --컨테이너 유형(PS)
                        ,NULL	            --WMS 결과값 Return( S:성공, E:오류 )
                        ,SYSDATE	        --MES 등록일시
                        ,NULL	            --WMS 전송일시
                        ,NULL	            --WMS 결과 메시지
                        ,NULL	            --MES Inserface Key(MES->WMS)
                        ,TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')	    --출고요청일시
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')	    --출고예정일자
                        ,V_SKNUM			--선적번호
                        ,V_DELIPOT			--하역지점                                              
               );
              	
              	V_ARR_HEAD		:=	V_JSON.get_array('head');
    			--20221222 여한진 작업지시에 하역지점 추가 
		    	IF V_WERKS = 'P100' THEN
					FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP
						V_OBJ2		:= TREAT(V_ARR_HEAD.get(i) AS json_object_t);
						V_OBJ2		:= TREAT(V_OBJ2.GET('map') AS json_object_t);
					
						V_WRK_ORDR_NO		:= V_OBJ2.get_string('WRK_ORDR_NO');		--작업지시번호
						V_WRK_ORDR_SEQNO	:= V_OBJ2.get_string('WRK_ORDR_SEQNO');		--작업지시순번 
						
						--제지 예외 생산인 경우
						IF SUBSTR(V_WRK_ORDR_NO, 3, 2) = 'EX' THEN
							OPEN WRK_ORDR_CUR FOR
								SELECT S019.WRK_ORDR_NO 
								  FROM TB_SCH020 S020, TB_SCH019 S019
								 WHERE S020.ORDER_NO = S019.ORDER_NO 
								   AND S020.LOT_NO = V_LOT_NO;
								
								LOOP
									FETCH WRK_ORDR_CUR INTO V_WRK_ORDR;
									EXIT WHEN WRK_ORDR_CUR%NOTFOUND;
									
									IF V_WRK_ORDR_NO = V_WRK_ORDR THEN
										UPDATE TB_SCH019 
										   SET DELIPOT = V_DELIPOT
										  	  ,UPDDATE = SYSDATE 
										  	  ,UPDID = V_SESS_USER_ID
										 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
										   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
								  
										--예외 생산 작업지시별 하역지점 이력  
										INSERT INTO TB_SCH021 (DOC_NO, DOC_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, DELIPOT, REGDATE, REGID)
														VALUES(V_DOC_NO, TO_CHAR(V_SEQ), V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DELIPOT, SYSDATE, V_SESS_USER_ID);
									END IF;
								END LOOP;
							
							CLOSE WRK_ORDR_CUR;
						END IF;   
					END LOOP;
		    		
				END IF;
		
			END IF;

        END LOOP;

    END IF;
    IF NVL(V_DOC_NO_1, ' ') <> ' '  THEN
        P_DOC_NO  := V_DOC_NO_1 ;
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
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD            := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--        RAISE;
END;

/
