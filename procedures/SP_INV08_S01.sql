
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV08_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_INV08_S01
 * PROGRAM NAME  : 자재불출/반납 요청이력
 * VERSION       : 1.0.0
 * DESCRIPTION   : 자재불출/반납 요청이력을 조회한다
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/08/08
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/08    1.0.0   유상호         Initial Version 
 * 2022/12/22	 1.0.1	 여한진		  요청 취소시 해당 작업지시 하역지점 삭제
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK001] : (CRUD) 실적테이블(HL) 정보
 *        - [TB_WRK002] : (CRUD) 실적테이블(PS) 정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_INV08_S01';     -- PROCEDURE NAME

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
	V_LOT_NO		TB_INV002.LOT_NO%TYPE;				--LOT번호
	
	V_INOUT_GU		VARCHAR(1);					--지시구분(N:정규, E:예외)
	
    --V_EDATE			TB_WRK001.PRD_DT%TYPE;		--종료생산일자
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_WRK_ORDR_NO	       TB_WRK001.WRK_ORDR_NO%TYPE;        --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_WRK001.WRK_ORDR_SEQNO%TYPE;     --작업지시순번
    V_ORDER_NO	           TB_WRK001.ORDER_NO%TYPE;           --오더번호
    V_USE_QTY              TB_INV010.USE_QTY%TYPE;            --사용량
    V_TABLE_NM             varchar2(20);                      --테이블명        
    V_MDOCNO               TB_IFS001.MDOCNO%TYPE;             --MES 문서번호
    V_PRD_DT		       TB_WRK001.PRD_DT%TYPE;	  		  --생산일자 
    V_IND_BCD		       TB_WRK001.IND_BCD%TYPE;        	  --개별바코드


    V_ORDR_QTY	           TB_SCH016.WRK_ORDR_QTY%TYPE;       --지시수량
    V_ORDR_GEN_DT	       TB_SCH016.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DATE	       TB_SCH016.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH016.WRK_ORDR_RMK%TYPE;       --작업지시비고
    V_USE_YN	           TB_SCH016.USE_YN%TYPE;             --사용여부
	V_COMP_YN	           TB_SCH016.COMP_YN%TYPE;            --확정여부
    V_MRLDCK	           TB_SCH016.MRLDCK%TYPE;             --밀롤창고적치여부
    V_CUTTER	           TB_SCH016.CUTTER%TYPE;             --카터
    V_WRK_SEQNO            TB_SCH016.WRK_SEQNO%TYPE;          --작업순서  



    V_MATNR	           	   TB_INV002.MATNR%TYPE;              --자재코드
    V_MATNR_DIV	           TB_MAS001.MATNR_DIV%TYPE;              --자재코드
    V_MACH_CD              VARCHAR2(10);
    V_DOC_NO               TB_INV002.DOC_NO%TYPE;
    V_DOC_SEQNO            TB_INV002.DOC_SEQ%TYPE;
   
    V_SDATE                VARCHAR(10); 
    V_EDATE                VARCHAR(10); 
    V_DATE                 DATE := SYSDATE;

   	--V_REQ_DIV              TB_INV002.REQ_DIV%TYPE;	--요청구분	
    --V_DLFL                 TB_INV002.DLFL%TYPE;		--삭제구분	
    --V_IF_STA               TB_INV002.IF_STA%TYPE;		--전송상태

    V_REQ_DIV              VARCHAR(20);	    --요청구분	
    V_DLFL                 VARCHAR(20);		--삭제구분	
    V_IF_STA               VARCHAR(20);		--전송상태
    
    WRK_ORDR_CUR			SYS_REFCURSOR;
	V_CNT					NUMBER;
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
    V_RANGE_SQL 		:=       V_JSON.get_string('RANGE_SQL');   	--생산일자
   --V_MACH_CD          :=       V_JSON.get_string('MACH_CD');   	--설비코드
    V_MATNR             :=       V_JSON.get_string('MATNR');   	    --자재코드
    V_SDATE             :=       V_JSON.get_string('SDATE');   	    --시작일자
    V_EDATE             :=       V_JSON.get_string('EDATE');   	    --종료일자
    V_MATNR_DIV         :=       V_JSON.get_string('MATNR_DIV');   	--자재유형

    V_REQ_DIV         	:=       V_JSON.get_string('REQ_DIV');   	--요청구분
    V_DLFL         		:=       V_JSON.get_string('DLFL');   		--삭제구분
    V_IF_STA         	:=       V_JSON.get_string('IF_STA');   	--전송상태
    V_LOT_NO			:=		V_JSON.get_string('LOT_NO');		--LOT_NO
    V_INOUT_GU			:=		V_JSON.get_string('INOUT_GU');		--지시구분(N:정규, E:예외)

    IF P_TYPE = 'LIST' THEN /*자재사용량 조회 리스트*/
        V_SQL := ' SELECT I002.DOC_NO,          --문서번호
                            I002.DOC_SEQ,      --문서번호 순번
                            CASE WHEN I002.REQ_DIV = ''10'' THEN ''불출요청'' ELSE ''반납요청'' END AS REQ_DIV,        --구분
                            CASE WHEN I002.DLFL = ''C'' OR I002.DLFL = ''N'' THEN ''정상'' ELSE ''삭제'' END AS DLFL, --삭제구분    
                            TO_CHAR(I002.REGDATE, ''YYYYMMDD'') REQ_DT,
                            I002.WERKS,          --플랜트
                            I002.MATNR,
                            M001.MATNR_NM       AS MATNR_NM,
                            M001.MATNR_DIV       AS MATNR_DIV,
                            I002.QTY,
                            I002.UNIT,
                            CASE WHEN I002.REQ_DIV = ''10'' THEN I002.STOR_LOC_TO ELSE I002.STOR_LOC_CD END STOR_LOC_CD,   --저장위치
                            (SELECT LAND1 FROM TB_MAS009 WHERE S019.KUNNR = CUST_CD AND CUST_DIV = ''C'') NTN_CD,
                            S019.KUNNR    AS CRSPD_CD,           --거래처코드MTO
                            (SELECT CUST_NM FROM TB_MAS009 WHERE S019.KUNNR = CUST_CD AND CUST_DIV = ''C'')    AS CUST_NM,                 --거래처명
                            --I002.PRDC_DT,            --제조일자
                            --I002.RCVGDS_DT,          --입고일자
                            --I002.DSTBT_DDLIN,        --유통기간
							FN_CD_VAL(''DELIPOT'', I002.DELIPOT)	DELIPOT,			--하역지점
                            --I002.IND_BCD,            --개별바코드
                            I002.LOT_NO,              --LOT NO
                            DECODE(I002.REQ_DIV, ''10'', S019.VBELN, I002.OVBELN) AS OVBELN,             --판매문서번호    
                            DECODE(I002.REQ_DIV, ''10'', S019.POSNR, I002.OPOSNR) AS OPOSNR,             --판매문서 항목번호
                            CASE WHEN I002.IF_STA = ''N'' THEN ''요청'' ELSE ''완료'' END AS IF_STA             -- WMS전송상태
						   ,I002.ORDER_NO			--오더번호
						   ,I002.ORDER_SEQNO		--오더순번
                      FROM TB_INV002 I002,
                           TB_MAS001 M001,
						   V_WRK_ORDR S019
                     WHERE I002.WERKS = M001.WERKS(+)
                       AND I002.MATNR = M001.MATNR(+)
					   AND I002.ORDER_NO = S019.ORDER_NO(+)
                       --AND I002.WERKS = ''' || V_WERKS ||'''
						';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                                -- 자재유형
            V_SQL := V_SQL || 'AND I002.WERKS = ''' || V_WERKS || '''';        
        END IF;
        
        IF  V_MATNR_DIV IS NOT NULL OR TRIM(V_MATNR_DIV) != '' THEN                                -- 자재유형
            V_SQL := V_SQL || 'AND M001.MATNR_DIV = ''' || V_MATNR_DIV || '''';        
        END IF;

       	--요청구분
		IF (V_REQ_DIV != 'ALL') THEN
			IF (V_REQ_DIV = '불출요청') THEN
				V_SQL := V_SQL || 'AND I002.REQ_DIV = ''10'' ';   
			ELSIF(V_REQ_DIV = '반납요청') THEN
				V_SQL := V_SQL || 'AND I002.REQ_DIV != ''10'' ';  
			END IF;        
		END IF;

		--삭제구분
		IF (V_DLFL != 'ALL') THEN
			IF (V_DLFL = '정상') THEN
				V_SQL := V_SQL || 'AND (I002.DLFL = ''C'' OR I002.DLFL = ''N'') ';   
			ELSIF(V_DLFL = '삭제') THEN
				V_SQL := V_SQL || 'AND (I002.DLFL != ''C'' AND I002.DLFL != ''N'') ';  
			END IF;        
		END IF;

		--전송상태
		IF (V_IF_STA != 'ALL') THEN
			IF (V_IF_STA = '요청') THEN
				V_SQL := V_SQL || 'AND I002.IF_STA = ''N'' ';   
			ELSIF(V_IF_STA = '완료') THEN
				V_SQL := V_SQL || 'AND I002.IF_STA != ''N'' ';  
			END IF;        
		END IF;
        
        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'I002.WERKS');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'REQ_DT', 'TO_CHAR(I002.REGDATE, ''YYYYMMDD'')');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'I002.MATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'I002.LOT_NO');
            
            V_SQL := V_SQL || V_RANGE_SQL ;			                       	               --자재코드(WRK_ORDR.MATNR) ,생산요청일자(WRK_ORDR.PRD_REQ_DT)
        END IF; 
       
       	V_SQL := V_SQL || 'ORDER BY I002.DOC_NO';
        
--        SZP_MES_PLSQL_LOG(V_SQL, 'INV08 V_SQL');
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'INV08_S01');
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SUB_LIST' THEN   
        V_ARR_HEAD      :=      TREAT(V_JSON.get ('list') AS json_object_t);
        V_OBJ           :=      TREAT(V_ARR_HEAD.get ('map') AS json_object_t);

        V_DOC_NO        :=      V_OBJ.get_string('DOC_NO');
        V_DOC_SEQNO     :=      V_OBJ.get_string('DOC_SEQ');

        V_SQL := ' SELECT DECODE(I007.DLFL, ''D'', ''취소'', ''요청'')   DIV,       --삭제지시자(구분)
                          I007.MATNR,              --자재코드
                          M001.MATNR_NM,           --자재명
                          I007.IND_BCD,            --개별바코드
                          I007.LOT_NO,             --LOT NO
                          I007.QTY,                --수량
                          I007.UNIT,               --단위
                          I007.STOR_LOC_FR,         --저장위치(FROM)
                          I007.STOR_LOC_TO,         --저장위치(TO)
                          FN_CD_VAL(''STCK_STA'', I007.STCK_STA) AS STCK_STA,            --재고상태
                          I007.PRDC_DT,             --제조일자
                          TO_CHAR(I007.REGDATE, ''YYYY-MM-DD'') AS RCVCDS_DT,
                         -- I007.RCVCDS_DT,            --입고일자  
                          I007.REGDATE              --불출/반납일시    
                     FROM TB_INV007 I007,
                          TB_MAS001 M001
                    WHERE I007.WERKS = M001.WERKS(+)
                      AND I007.MATNR = M001.MATNR(+)
                      AND I007.DOC_NO = ''' || V_DOC_NO || '''
                      AND I007.DOC_SEQNO = ''' || V_DOC_SEQNO || '''';

        OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'SAVE' THEN  /*요청취소 */

        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ						:= TREAT (V_ARR_LIST.get (i) AS json_object_t);  
            V_OBJ						:= TREAT (V_OBJ.get ('map') AS json_object_t);   

            V_DOC_NO	                := V_OBJ.get_string('DOC_NO');          --문서번호
            V_DOC_SEQNO	                := V_OBJ.get_string('DOC_SEQ');         --문서번호 항목
            V_WERKS	                    := V_OBJ.get_string('WERKS');           --플랜트코드
            V_REQ_DIV                   := V_OBJ.get_string('REQ_DIV');         --구분
            V_DLFL                      := V_OBJ.get_string('DLFL');            --삭제지시자
            V_LOT_NO					:= V_OBJ.get_string('LOT_NO');			--LOT번호
            --V_IF_STA                    := V_OBJ.get_string('IF_STA');            --전송상태
			
            IF NVL(P_DOC_NO1, ' ') = ' ' THEN
                P_DOC_NO1 := V_DOC_NO;
            ELSE
                P_DOC_NO1 := P_DOC_NO1 || ',' || V_DOC_NO;
            END IF;

--            INSERT INTO TB_INV002(DOC_NO, DOC_SEQ, DLFL, REQ_DIV, WERKS, MATNR, QTY, UNIT,
--                                STOR_LOC_CD, STOR_LOC_TO, STCK_STA, WRK_ORDR_NO, WRK_ORDR_SEQNO, STCK_KY, LOT_NUM,
--                                NTN_CD, CRSPD_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,IND_BCD, LOT_NO, OVBELN, OPOSNR,
--                                IF_STA, REGDATE, REGID)
--                    SELECT DOC_NO, DOC_SEQ, 'D', REQ_DIV, WERKS, MATNR, QTY, UNIT,
--                                STOR_LOC_CD, STOR_LOC_TO, STCK_STA, WRK_ORDR_NO, WRK_ORDR_SEQNO, STCK_KY, LOT_NUM,
--                                NTN_CD, CRSPD_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,IND_BCD, LOT_NO, OVBELN, OPOSNR,
--                                'N', V_DATE, V_SESS_USER_ID
--                      FROM TB_INV002
--                     WHERE DOC_NO = V_DOC_NO
--                       AND DOC_SEQ = V_DOC_SEQNO;

            IF V_REQ_DIV = '불출요청' THEN
                INSERT INTO TB_IFSWM002(DOC_NO, DOC_SEQNO, DLFL, WERKS, MATNR, QTY, UNIT,
                                        STOR_LOC, ORDER_NO, ORDER_SEQNO, STCK_STA, NTN_CD, CRSPD_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
                                        IND_BCD, LOT_NO, OVBELN, OPOSNR, IF_STATUS, IF_GET_DATE, REQ_DTM, REQ_EXE_DT)
                           SELECT DOC_NO, DOC_SEQNO, 'D', WERKS, MATNR, QTY, UNIT,
                                        STOR_LOC, ORDER_NO, ORDER_SEQNO, STCK_STA, NTN_CD, CRSPD_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
                                        IND_BCD, LOT_NO, OVBELN, OPOSNR, 'N', V_DATE, REQ_DTM, REQ_EXE_DT
                             FROM TB_IFSWM002
                            WHERE DOC_NO = V_DOC_NO  
                              AND DOC_SEQNO = V_DOC_SEQNO
                              AND DLFL = 'C';
            ELSE
                INSERT INTO TB_IFSWM004(DOC_NO, DOC_SEQNO, DLFL, WERKS, MATNR, QTY, UNIT,
                                    STOR_LOC_FROM, STOR_LOC_TO, STCK_STA, STOK_KY, LOT_NUM, NTN_CD, CRSPD_CD, PRDC_DT,
                                    RCVGDS_DT, DSTBT_DDLIN, IND_BCD, LOT_NO, 
                                    IF_STATUS, IF_GET_DATE, RTN_DT, LOTA03, LOTA04, LOTA16, LOTA17)
                         SELECT DOC_NO, DOC_SEQNO, 'D', WERKS, MATNR, QTY, UNIT,
                                    STOR_LOC_FROM, STOR_LOC_TO, STCK_STA, STOK_KY, LOT_NUM, NTN_CD, CRSPD_CD, PRDC_DT,
                                    RCVGDS_DT, DSTBT_DDLIN, IND_BCD, LOT_NO, 
                                    'N', V_DATE, RTN_DT, LOTA03, LOTA04, LOTA16, LOTA17
                           FROM TB_IFSWM004
                          WHERE DOC_NO = V_DOC_NO
                            AND DOC_SEQNO = V_DOC_SEQNO
                            AND DLFL = 'C';
              
					-- 반납요청 취소 시 TB_INV001.STCK_STA = '00'으로 변경 처리 시작
		            BEGIN
			            SELECT	IND_BCD INTO V_IND_BCD
			            FROM	TB_IFSWM004
			            WHERE 	DOC_NO = V_DOC_NO
			       	    AND		DOC_SEQNO = V_DOC_SEQNO
			       	    AND		DLFL = 'D'
			       	    AND		ROWNUM = 1;
		            EXCEPTION
		                WHEN NO_DATA_FOUND THEN
		                    V_IND_BCD := '00';
			        END;

			       	IF NVL(V_IND_BCD, '00') != '00'	THEN
			       	    UPDATE	TB_INV001
			       	    SET
                            STCK_STA    = '00'
                            , UPDDATE   = SYSDATE
                            , UPDID     = V_SESS_USER_ID
                            , SND_MSG   = '반납요청취소'
			       	    WHERE	IND_BCD = V_IND_BCD;
			       	END IF;
					-- 반납요청 취소 시 TB_INV001.STCK_STA = '00'으로 변경 처리 끝
            END IF;
           
			--20221222 여한진 작업지시에 저장되어 있는 하역지점 삭제
            OPEN WRK_ORDR_CUR FOR
	           	SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO
	           	  FROM TB_SCH021 ts
	           	 WHERE DOC_NO = V_DOC_NO
	           	   AND DOC_SEQNO = V_DOC_SEQNO;
	           	
	           	LOOP
	           		FETCH WRK_ORDR_CUR INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO;
	           		EXIT WHEN WRK_ORDR_CUR%NOTFOUND;
	           		
	           		--취소할 문서번호가 아닌 다른 문서번호에 취소하지 않은 작업지시가 있는지 체크
	      			SELECT COUNT(*) INTO V_CNT
	      			  FROM TB_SCH021
	      			 WHERE DOC_NO <> V_DOC_NO
	      			   AND WRK_ORDR_NO = V_WRK_ORDR_NO
	      			   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	      			   AND NVL(CNL_YN, 'N') = 'N';
	      			  
	      			IF V_CNT = 0 THEN
	      				--작업지시가 취소가 되었으므로 하역지점 삭제
	      				UPDATE TB_SCH019 
	      				   SET DELIPOT = NULL
	      				   	  ,UPDDATE = SYSDATE 
	      				   	  ,UPDID = V_SESS_USER_ID
	      				 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
	      				   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
	      			END IF;
	           	END LOOP;
	           
            CLOSE WRK_ORDR_CUR;
	     	
           	UPDATE TB_SCH021 
		 	   SET CNL_YN = 'Y'
		 	      ,UPDDATE = SYSDATE
		 	      ,UPDID = V_SESS_USER_ID
		 	 WHERE DOC_NO = V_DOC_NO
		 	   AND DOC_SEQNO = V_DOC_SEQNO;
           
            UPDATE TB_INV002
               SET DLFL = 'D',
                   UPDDATE = V_DATE,
                   UPDID = V_SESS_USER_ID
             WHERE DOC_NO = V_DOC_NO
               AND DOC_SEQ = V_DOC_SEQNO
               AND DLFL = 'C';

        END LOOP;

    END IF;

    P_SUCCESS := 'Y';
    COMMIT;

    /*EXCEPTION
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);*/
END;
/
