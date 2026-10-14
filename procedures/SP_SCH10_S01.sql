
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH10_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH10_S01
 * PROGRAM NAME  : 작업지시 기저귀 
 * VERSION       : 1.0.0
 * DESCRIPTION   : 작업지시 기저귀  를 관리한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/04/29
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/29    1.0.0   박충식         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH014] : (CRUD) 작업지시 기저귀  정보
 * *      
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH10_S01';     -- PROCEDURE NAME

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

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

    V_WRK_ORDR_NO	       TB_SCH014.WRK_ORDR_NO%TYPE;        --작업지시번호
    V_WRK_ORDR_SEQNO	   TB_SCH014.WRK_ORDR_SEQNO%TYPE;     --작업지시순번
    V_ORDER_NO	           TB_SCH014.ORDER_NO%TYPE;           --오더번호
    V_ORDR_QTY	           TB_SCH014.WRK_ORDR_QTY%TYPE;       --지시수량
    V_ORDR_GEN_DT	       TB_SCH014.ORDR_GEN_DT%TYPE;        --지시생성일자
    V_PRD_REQ_DT	       TB_SCH014.PRD_REQ_DT%TYPE;         --생산요청일자
    V_WRK_ORDR_REMARK	   TB_SCH014.WRK_ORDR_RMK%TYPE;      --작업지시비고
    V_USE_YN	           TB_SCH014.USE_YN%TYPE;             --사용여부
    V_USE_FLAG	           TB_SCH014.USE_YN%TYPE;             --오더 삭제여부
	V_COMP_YN	           TB_SCH014.COMP_YN%TYPE;            --확정여부 
    V_WRK_SEQNO            TB_SCH014.WRK_SEQNO%TYPE;          --작업순서    

    V_MATNR	           	   TB_SCH014.MATNR%TYPE;              --자재코드
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
   V_USE_FLAG           :=       V_JSON.get_string('USE_FLAG');     --오더 삭제여부

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT
                       SCH014.WERKS       		 WERKS            		--플랜트
	                 , SCH014.ORDR_GEN_DT 		 ORDR_GEN_DT			--지시생성일자
	                 , SCH014.WRK_ORDR_NO 		 WRK_ORDR_NO			--작업지시번호
                     , SCH014.WRK_ORDR_SEQNO 	 WRK_ORDR_SEQNO			--작업지시순번
	                 , SCH014.WRK_ORDR_QTY 		 WRK_ORDR_QTY			--지시량
	                 , SCH014.MACHINE     		 MACHINE				--생산호기
	                 , SCH014.PRD_REQ_DT		 PRD_REQ_DT				--생산요청일자
	                 , SCH014.ORDER_NO      	 ORDER_NO			    --오더번호
                     , SCH014.ORDER_SEQNO      	 ORDER_SEQNO			--오더순번
                     , SCH014.WRK_SEQNO          WRK_SEQNO              --작업순서 
	                 , SCH014.MATNR       		 MATNR					--자재코드
	                 , MAS001.MATNR_NM	   	     MATNR_NM				--자재명
	                 , SCH014.ORDER_QTY	  		 FQTY					--오더량
	                 , SCH014.UNIT		  		 UNIT					--단위
                     , NULL					     PQTY					--팔레트 적재수량
					 , SCH014.PRFM_QTY			 PRFM_QTY				--실적수량
	                 , TO_DATE(SCH014.PRD_STR_DTM, ''YYYY-MM-DD HH24:MI:SS'') 		 PRD_STR_DTM			--생산시작시간
	                 , TO_DATE(SCH014.PRD_END_DTM, ''YYYY-MM-DD HH24:MI:SS'') 		 PRD_END_DTM			--생산완료시간
	                 , NVL(SCH014.COMP_YN,''N'')   COMP_YN				--작업지시완료 (N:대기 I:작업중 Y:완료)
                     , DECODE(NVL(SCH014.USE_YN,''Y''), ''N'', ''작업지시 삭제'', ''Y'',
						NVL(FN_CMCDV(''COMP_YN'',SCH014.COMP_YN ),''대기''))
                                                 COMP_YN_NM				--작업지시완료명 (N:대기 I:작업중 Y:완료)                     
	                 , SCH014.ORDER_RMK		     PLN_ORDR_REMARK		--계획오더비고
	                 , SCH014.WRK_ORDR_RMK       WRK_ORDR_REMARK		--작업지시비고
	                 , SCH014.REGDATE            REGDATE				--등록일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH014.REGID),'''')	             REGNM					--등록자
	                 , SCH014.UPDDATE            UPDDATE				--수정일시
	                 , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = SCH014.UPDID),'''')				 UPDNM					--수정자
					 , NVL(SCH014.USE_YN,''Y'') 											   				USE_STATE
                     , DECODE(NVL(SCH014.USE_YN,''Y''), ''Y'', ''사용'', ''오더 삭제'')  USE_FLAG				--오더 삭제여부 (Y:사용 N:오더 삭제)
                FROM TB_SCH014 SCH014, TB_MAS001    MAS001
               WHERE SCH014.MATNR  = MAS001.MATNR(+) 
                 AND SCH014.WERKS  = MAS001.WERKS(+)  '
                 ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND SCH014.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        END IF;

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND SCH014.MACHINE = ''' || V_MACHINE || '''';			   --생산호기
        END IF;

       /* IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND SCH014.MATNR = ''' || V_MATNR || '''';			   	   --자재코드
        END IF;*/

       	IF 	V_USE_FLAG IS NOT NULL OR TRIM(V_USE_FLAG) != '' THEN
        	V_SQL :=V_SQL || ' AND NVL(SCH014.USE_YN,''Y'') = ''' || V_USE_FLAG || '''';	--오더 삭제여부(N,Y)
        END IF;

        IF 	V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
       		V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'SCH014.MATNR');				--자재코드
       		V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ORDER_NO', 'SCH014.ORDER_NO');	--오더번호
        	V_SQL := V_SQL || V_RANGE_SQL ;			                       	               
        END IF;

        V_SQL := V_SQL || ' ORDER BY SCH014.WERKS, SCH014.PRD_REQ_DT, TO_NUMBER(SCH014.WRK_SEQNO)';  

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
            V_ORDER_NO	                := V_OBJ.get_string('WRK_ORDER_NO');           --오더번호
            V_ORDR_QTY	                := V_OBJ.get_string('WRK_ORDR_QTY');           --지시수량
            V_ORDR_GEN_DT	            := V_OBJ.get_string('ORDR_GEN_DT');        --지시생성일자
            V_PRD_REQ_DT	            := V_OBJ.get_string('PRD_REQ_DT');       --생산요청일자
            V_WRK_ORDR_REMARK	        := V_OBJ.get_string('WRK_ORDR_REMARK');    --작업지시비고
            --V_USE_YN	                := V_OBJ.get_string('USE_YN');             --사용여부
            V_COMP_YN	                := V_OBJ.get_string('COMP_YN');            --확정여부
            V_WRK_SEQNO                 := V_OBJ.get_string('WRK_SEQNO');          --작업순서    

            IF V_OBJ.get_string('GRowState') = 'C'   THEN
                SELECT NVL(MAX(WRK_ORDR_SEQNO) + 1, 1)
                  INTO V_WRK_ORDR_SEQNO
                  FROM TB_SCH014
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO ;

                INSERT INTO TB_SCH014 (
                             WRK_ORDR_NO	            --작업지시번호
                            ,WRK_ORDR_SEQNO	            --작업지시순번
                            ,WERKS	                    --플랜트코드
                            ,ORDER_NO	                --오더번호
                            ,WRK_SEQNO	                --작업순서
                            ,WRK_ORDR_QTY	            --생산지시량
                            ,ORDR_GEN_DT	            --지시생성일자
                            ,PRD_REQ_DT	                --생산요청일자
                            ,WRK_ORDR_RMK	            --작업지시비고
                            ,PRD_STR_DTM	            --생산시작일시
                            ,PRD_END_DTM	            --생산완료일시
                            ,PRFM_QTY	                --실적수량
                            ,COMP_YN	                --완료여부
                            ,USE_YN	                    --사용여부(Y/N)
                            ,ORDER_DIV	                --오더유형
                            ,ORDER_DIV_NM	            --오더유형 텍스트
                            ,MATNR	                    --제품코드
                            ,ORDER_QTY	                --오더수량
                            ,UNIT	                    --생산지시단위
                            ,WORK_ORDER	                --작업지시자
                            ,TO_MACHINE	                --TO 생산호기
                            ,MACHINE	                --생산호기
                            ,BOM_NO	                    --BOM Num
                            ,ATN_BOM_NO	                --대체Bom
                            ,PRT_MATNR_UNIT	            --모품목기준수량 단위
                            ,PRT_MATNR_QTY	            --모품목기준수량
                            ,RES_DT	                    --릴리즈일자
                            ,VBELN	                    --판매문서번호
                            ,POSNR	                    --판매문서Item번호
                            ,SPEC	                    --규격
                            ,WIDTH_CNT	                --폭수
                            ,PUPOS	                    --용도
                            ,PUPNM	                    --용도내역
                            ,ORDER_RMK	                --오더비고
                            ,DLFL	                    --오더 삭제 지시자
                            ,WRK_CD	                    --작업장코드
                            ,PRD_END_DT	                --생산종료일
                            ,MACH_CD	                --설비코드
                            ,ORDER_SEQNO	            --오더순번
                            ,REGDATE	                --등록일시
                            ,REGID	                    --등록자ID
                            ,UPDDATE	                --수정일시
                            ,UPDID	                    --수정자ID
                )   
                SELECT
                             SCH014.WRK_ORDR_NO	            --작업지시번호
                            ,V_WRK_ORDR_SEQNO	            --작업지시순번
                            ,SCH014.WERKS                   --플랜트코드
                            ,SCH014.ORDER_NO	            --오더번호
                            ,V_WRK_SEQNO     	            --작업순서
                            ,V_ORDR_QTY	                    --생산지시량
                            ,TO_CHAR(SYSDATE, 'YYYYMMDD')	--지시생성일자
                            ,SCH014.PRD_REQ_DT	            --생산요청일자
                            ,V_WRK_ORDR_REMARK	            --작업지시비고
                            ,NULL	                        --생산시작일시
                            ,NULL	                        --생산완료일시
                            ,NULL	                        --실적수량
                            ,'N'	                        --완료여부
                            ,'Y'	                        --사용여부(Y/N)
                            ,SCH014.ORDER_DIV	            --오더유형
                            ,SCH014.ORDER_DIV_NM	        --오더유형 텍스트
                            ,SCH014.MATNR	                --제품코드
                            ,SCH014.ORDER_QTY	            --오더수량
                            ,SCH014.UNIT	                --생산지시단위
                            ,SCH014.WORK_ORDER	            --작업지시자
                            ,SCH014.TO_MACHINE	            --TO 생산호기
                            ,SCH014.MACHINE	                --생산호기
                            ,SCH014.BOM_NO	                --BOM Num
                            ,SCH014.ATN_BOM_NO	            --대체Bom
                            ,SCH014.PRT_MATNR_UNIT	        --모품목기준수량 단위
                            ,SCH014.PRT_MATNR_QTY	        --모품목기준수량
                            ,SCH014.RES_DT	                --릴리즈일자
                            ,SCH014.VBELN	                --판매문서번호
                            ,SCH014.POSNR	                --판매문서Item번호
                            ,SCH014.SPEC	                --규격
                            ,SCH014.WIDTH_CNT	            --폭수
                            ,SCH014.PUPOS	                --용도
                            ,SCH014.PUPNM	                --용도내역
                            ,SCH014.ORDER_RMK	            --오더비고
                            ,SCH014.DLFL	                --오더 삭제 지시자
                            ,SCH014.WRK_CD	                --작업장코드
                            ,SCH014.PRD_END_DT	            --생산종료일
                            ,SCH014.MACH_CD	                --설비코드
                            ,SCH014.ORDER_SEQNO	            --오더순번
                            ,SYSDATE		                --등록일시
                            ,V_SESS_USER_ID	                --등록자ID
                            ,NULL		                    --수정일시
                            ,NULL	                        --수정자ID
                  FROM TB_SCH014 SCH014
                 WHERE SCH014.WRK_ORDR_NO = V_WRK_ORDR_NO	                      --작업지시번호
                   AND ROWNUM = 1 ;

                 /*DELETE FROM TB_SCH020    --작업지시 BOM
                 WHERE WERKS          = V_WERKS            --플랜트코드
                   AND WRK_ORDR_NO    = V_WRK_ORDR_NO      --작업지시번호
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO   --작업지시번호 순번
                 ;

                 INSERT INTO TB_SCH020    --작업지시 BOM
                 (
                         WERKS	            --플랜트코드
                        ,WRK_ORDR_NO	    --작업지시번호
                        ,WRK_ORDR_SEQNO	    --작업지시번호 순번
                        ,MATNR	            --자품목자재
                        ,ORDER_NO	        --오더번호
                        ,ORDER_ITM_NO	    --오더Item번호
                        ,ORDER_BOM_QTY	    --오더BOM 수량
                        ,UNIT	            --수량단위
                        ,STOR_LOC_CD	    --저장위치
                        ,LOT_NO	            --LOT NO
                        ,CHGFL	            --대체자재 여부
                        ,EMPLY_NO	        --대체자재 등록자
                        ,DLFL	            --삭제여부
                        ,DOC_NO	            --MES문서번호
                        ,DOC_SEQ	        --MES 문서순번
                        ,REGDATE	        --등록일시
                        ,REGID	            --등록자ID                 
                 ) 
                 SELECT
                         SCH014.WERKS	        --플랜트코드
                        ,SCH014.WRK_ORDR_NO	    --작업지시번호
                        ,SCH014.WRK_ORDR_SEQNO  --작업지시번호 순번
                        ,SCH001.MATNR	        --자품목자재
                        ,SCH001.AUFNR	        --오더번호
                        ,SCH001.POSNR	        --오더Item번호
                        ,CASE WHEN SCH014.ORDER_QTY = 0      THEN  SCH014.WRK_ORDR_QTY
                              WHEN SCH014.ORDER_QTY IS NULL  THEN  SCH014.WRK_ORDR_QTY
                              ELSE ((SCH014.WRK_ORDR_QTY/SCH014.ORDER_QTY) * 100)/100 *  SCH001.BDMNG
                          END                   --오더BOM 수량  
                        ,SCH001.MEINS	        --수량단위
                        ,SCH001.LGORT	        --저장위치
                        ,NULL	                --LOT NO
                        ,NULL	                --대체자재 여부
                        ,NULL	                --대체자재 등록자
                        ,SCH001.XLOEK	        --삭제여부
                        ,NULL	                --MES문서번호
                        ,NULL    	            --MES 문서순번
                        ,SYSDATE	            --등록일시
                        ,V_SESS_USER_ID	        --등록자ID                                  
                    FROM TB_SCH014  SCH014   --작업지시 화장지초지
                       , TB_SCH001  SCH001   --생산오더 BOM - 릴리즈된 생산오더
                   WHERE SCH014.WRK_ORDR_NO	   = V_WRK_ORDR_NO            --작업지시번호
                     AND SCH014.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO	      --작업지시순번 
                     AND SCH014.ORDER_NO       = SCH001.AUFNR             --오더번호
                  ;      */ 

            ELSIF V_OBJ.get_string('GRowState') = 'U'  THEN

                -- 완료여부 : N:대기 I:작업중 Y:완료
                SELECT COMP_YN
                  INTO V_COMP_YN
                  FROM TB_SCH014
                 WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO 
                   AND WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO   ; 

                IF NVL(V_COMP_YN,'N') = 'N' THEN   -- N:대기 경우일때만 변경 실행
                    --20220919 여한진 생산요청일자 수정가능하도록
                    UPDATE TB_SCH014 
                    SET   PRD_REQ_DT        = V_PRD_REQ_DT                  --생산요청일자 
                         ,WRK_ORDR_QTY      = V_ORDR_QTY                    --지시량
                         ,WRK_ORDR_RMK      = V_WRK_ORDR_REMARK             --작업지시비고
                         ,WRK_SEQNO         = V_WRK_SEQNO                   --작업순서
                         ,UPDDATE		    = SYSDATE			            --수정일자
                         ,UPDID			    = V_SESS_USER_ID	            --수정자   
                         --,USE_YN            = V_USE_YN                      --사용여부   (Y:사용 N:미사용)
                    WHERE WRK_ORDR_NO		= V_WRK_ORDR_NO    AND			--작업지시번호
                          WRK_ORDR_SEQNO    = V_WRK_ORDR_SEQNO   ;          --작업지시순번            

                     /*DELETE FROM TB_SCH020    --작업지시 BOM
                     WHERE WERKS          = V_WERKS            --플랜트코드
                       AND WRK_ORDR_NO    = V_WRK_ORDR_NO      --작업지시번호
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO   --작업지시번호 순번
                     ;

                     INSERT INTO TB_SCH020    --작업지시 BOM
                     (
                             WERKS	            --플랜트코드
                            ,WRK_ORDR_NO	    --작업지시번호
                            ,WRK_ORDR_SEQNO	    --작업지시번호 순번
                            ,MATNR	            --자품목자재
                            ,ORDER_NO	        --오더번호
                            ,ORDER_ITM_NO	    --오더Item번호
                            ,ORDER_BOM_QTY	    --오더BOM 수량
                            ,UNIT	            --수량단위
                            ,STOR_LOC_CD	    --저장위치
                            ,LOT_NO	            --LOT NO
                            ,CHGFL	            --대체자재 여부
                            ,EMPLY_NO	        --대체자재 등록자
                            ,DLFL	            --삭제여부
                            ,DOC_NO	            --MES문서번호
                            ,DOC_SEQ	        --MES 문서순번
                            ,REGDATE	        --등록일시
                            ,REGID	            --등록자ID                 
                     ) 
                     SELECT
                             SCH014.WERKS	        --플랜트코드
                            ,SCH014.WRK_ORDR_NO	    --작업지시번호
                            ,SCH014.WRK_ORDR_SEQNO  --작업지시번호 순번
                            ,SCH001.MATNR	        --자품목자재
                            ,SCH001.AUFNR	        --오더번호
                            ,SCH001.POSNR	        --오더Item번호
                            ,CASE WHEN SCH014.ORDER_QTY = 0      THEN  SCH014.WRK_ORDR_QTY
                              WHEN SCH014.ORDER_QTY IS NULL  THEN  SCH014.WRK_ORDR_QTY
                              ELSE ((SCH014.WRK_ORDR_QTY/SCH014.ORDER_QTY) * 100)/100 *  SCH001.BDMNG
                              END                   --오더BOM 수량  
                            ,SCH001.MEINS	        --수량단위
                            ,SCH001.LGORT	        --저장위치
                            ,NULL	                --LOT NO
                            ,NULL	                --대체자재 여부
                            ,NULL	                --대체자재 등록자
                            ,SCH001.XLOEK	        --삭제여부
                            ,NULL	                --MES문서번호
                            ,NULL    	            --MES 문서순번
                            ,SYSDATE	            --등록일시
                            ,V_SESS_USER_ID	        --등록자ID                                  
                        FROM TB_SCH014  SCH014   --작업지시 화장지초지
                           , TB_SCH001  SCH001   --생산오더 BOM - 릴리즈된 생산오더
                       WHERE SCH014.WRK_ORDR_NO	   = V_WRK_ORDR_NO            --작업지시번호
                         AND SCH014.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO	      --작업지시순번 
                         AND SCH014.ORDER_NO       = SCH001.AUFNR             --오더번호
                      ;   */    

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
