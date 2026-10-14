--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_STOCK_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : MIG01
 * PROGRAM NAME  : 초기재고SETUP
 * VERSION       : 1.0.0
 * DESCRIPTION   : 초기재고SETUP
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/09/05
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/05    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TX_SAP_INIT] : ( R  ) SAP초기재고 
 *        - [TX_PIS_INIT] 	: ( R  ) PIS초기재고
 *        - [TX_BASE_INIT] : ( I  ) 초기재고 테이블
 *        - [INTSTKP@KNRAWMSLINK] : (.R..) PIS데이터 없을시 WMS데이터 참조
 *[PTYPE사용법]--------------------------------------------------------------------------------------------------------------
 *LIST : 등록된 초기재고데이타를 조회(개별바코드번호사용)
 *SCAN:개별바코드번호를 스캔하여 SAP,PIS정보 조회-->초기재고데이터 등록전 사용
 *SAVE:스캔하여 데이타 조정후 초기재고데이터를 등록 한다.
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_IF_MIG_STOCK_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON		      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
  V_OBJ               JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역

	V_SQL				        CLOB;
		
  V_WERKS      		  TX_BASE_INIT.WERKS%TYPE;      					--플랜트       	
  V_MACH_CD           TX_BASE_INIT.MACH_CD%TYPE;              --설비코드      
  V_STOR_LOC_CD       TX_BASE_INIT.STOR_LOC_CD%TYPE;          --저장위치      
  V_LOC_CD            TX_BASE_INIT.LOC_CD%TYPE;               --로케이션      
  V_MATNR             TX_BASE_INIT.MATNR%TYPE;                --자재코드      
  V_LOT_NO            TX_BASE_INIT.LOT_NO%TYPE;               --LOT번호     
  V_IND_BCD           TX_BASE_INIT.IND_BCD%TYPE;              --개별바코드     
  V_ORDER_NO          TX_BASE_INIT.ORDER_NO%TYPE;             --오더번호      
  V_MACHINE           TX_BASE_INIT.MACHINE%TYPE;              --생산호기      
  V_PROC_CD           TX_BASE_INIT.PROC_CD%TYPE;              --공정        
  V_PRD_DT            TX_BASE_INIT.PRD_DT%TYPE;               --생산일자      
  V_PRFM_DT           TX_BASE_INIT.PRFM_DT%TYPE;              --제조일자      
  V_DSTBT_DDLIN       TX_BASE_INIT.DSTBT_DDLIN%TYPE;          --유통기간      
  V_PCODE             TX_BASE_INIT.PCODE%TYPE;                --지종        
  V_UNIT              TX_BASE_INIT.UNIT%TYPE;                 --단위        
  V_ROLLCNT           TX_BASE_INIT.ROLLCNT%TYPE;              --실적_권치수    
  V_PCNT              TX_BASE_INIT.PCNT%TYPE;                 --실적_연수_REAM
  V_SCNT              TX_BASE_INIT.SCNT%TYPE;                 --실적_속당매수   
  V_MCNT              TX_BASE_INIT.MCNT%TYPE;                 --실적_속수     
  V_WGT               TX_BASE_INIT.WGT%TYPE;                  --실적_중량     
  V_CORE              TX_BASE_INIT.CORE%TYPE;                 --지관        
  V_BS_WGT            TX_BASE_INIT.BS_WGT%TYPE;               --평량        
  V_PACKTYPE          TX_BASE_INIT.PACKTYPE%TYPE;             --포장타입      
  V_CONTYPE           TX_BASE_INIT.CONTYPE%TYPE;              --컨테이너유형    
  V_WLEN              TX_BASE_INIT.WLEN%TYPE;                 --가로길이      
  V_VLEN              TX_BASE_INIT.VLEN%TYPE;                 --세로길이      
  V_WIDTH             TX_BASE_INIT.WIDTH%TYPE;                --지폭        
  V_VBELN             TX_BASE_INIT.VBELN%TYPE;                --판매문서번호    
  V_POSNR             TX_BASE_INIT.POSNR%TYPE;                --판매문서항목번호  
  V_KUNNR             TX_BASE_INIT.KUNNR%TYPE;                --판매처_MTO   
  V_MRG_YN            TX_BASE_INIT.MRG_YN%TYPE;               --라벨병합여부    
  V_WRK_CLASS         TX_BASE_INIT.WRK_CLASS%TYPE;            --작업반       
  V_WRK_SHIFT         TX_BASE_INIT.WRK_SHIFT%TYPE;            --작업조
  V_WGT_CHG           TX_BASE_INIT.WGT%TYPE;                  --중량 단위환산
	
	
	--임시사용변수 선언
	V_CNT               NUMBER        := 0;
		

BEGIN
    OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	      := V_JSON.get_string('SES_USER_ID');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	V_IND_BCD			  := V_JSON.get_string('IND_BCD');	                              --개별바코드
		

	--V_IND_BCD := SUBSTR(V_IND_BCD, 1, 10);
    
    IF P_TYPE = 'LIST' THEN  
            V_SQL :=' SELECT I001.WERKS                  --플랜트코드
                            ,I001.STOR_LOC_CD            --저장위치
                            ,M003.STOR_LOC_NM            --저장위치명
                            ,I001.IND_BCD                --개별바코드
                            ,I001.MATNR                  --제품코드
                            ,I001.LOC_CD                 --로케이션
                            ,I001.LOT_NO                 --LOT NO
                            ,I001.MACH_CD                --설비코드
                            ,I001.MACHINE                --생산호기
                            ,I001.WRK_ORDR_NO            --작업지시번호
                            ,I001.WRK_ORDR_SEQNO         --작업지시번호 순번
                            ,I001.ORDER_NO               --오더번호
                            ,I001.PRD_NO                 
                            ,I001.IN_MR_YN               --수입밀롤 여부
                            ,I001.STCK_KY                --LOTNUM WMS KEY(저장키)
                            ,I001.PRFM_DT                --실적일자
                            ,I001.PRD_DT                 --제조(생산)일자
                            ,I001.UNIT                   --단위
                            ,DECODE(NVL(I001.STCK_QTY, 0), 0, W002.PRFM_QTY, I001.STCK_QTY) STCK_QTY    --재고수량
                            ,I001.PLT_QTY                --PLT 수량
                            ,I001.BOX_QTY                --BOX 수량
                            ,I001.BAG_QTY                --BAG 수량
                            ,I001.EA_QTY                 --EA 수량
                            ,I001.ROLLCNT                --권치수(점보롤, 밀롤, 합지기)
                            ,I001.WGT                    --중량(재단,포장공정)
                            ,I001.SUPY_CD                --공급업체코드
                            ,I001.LOT_NUM                --LOTNUM WMS KEY(WMS LOT 속성 KEY)
                            ,I001.STCK_STA               --재고상태(00:정상, 10:투입, 20:생산실적, 30:불용, 40:부적합, 50:폐기)
                            ,I001.VBELN                  --판매문서
                            ,I001.POSNR                  --판매문서 항목번호
                            ,I001.KUNNR                  --판매처
                            ,I001.FNL_JDGM               --품질판정
                            ,I001.MSRM_DATE              --측정일시
                            ,I001.PRC_SEQNO              --처리순번
                            ,I001.INSPR_ID               --검사자
                            ,I001.CHK_PP_YN              --생산확인여부
                            ,I001.CHK_PP_DATE            --생산확인일시
                            ,I001.CHK_PP_ID              --생산확인자
                            ,I001.CHK_QC_YN              --품질확인여부
                            ,I001.CHK_QC_DATE            --품질확인일시
                            ,I001.CHK_QC_ID              --품질확인자
                            ,I001.DOC_NO                 --MES 문서번호
                            ,I001.DOC_SEQNO              --MES 문서번호순번
                            ,I001.WDOC_NO                --WMS 참조문서 번호
                            ,I001.WDOC_SEQNO             --WMS 참조문서아이템
                            ,I001.DLFL                   --삭제 지시자(C:출고, D:삭제)
                            ,I001.REGDATE                --등록일시
                            ,I001.REGID                  --등록자
                            ,I001.UPDDATE                --수정일시
                            ,I001.UPDID                  --수정자
                            ,I001.RUN_STA                --운전상태
                            ,I001.APVR_STA               --결재상태
                            ,I001.CFRM_ID                --승인자
                            ,I001.CFRM_DATE              --승인일시
                            ,I001.BS_WGT                 --평량
                            ,I001.CON_TYPE               --컨테이너유형
                            ,I001.PACK_TYPE              --포장타입
                            ,I001.DISPO_DT               --폐기일자
                            ,I001.DISPO_QTY              --폐기수량
                            ,I001.SDOC_NO                --SAP 확정문서
                            ,I001.SDOC_SEQNO             --SAP 확정문서항목번호
                            ,I001.DOC_ID                 --결제ID
                            ,I001.SND_MSG                --전송메시지
                            ,I001.UCFMTY_AMT             --부적합수량
                            ,I001.UCFMTY_FLG             --부적합처리여부
                            ,I001.MER_STOCK_QTY          --라벨병합 전 재고
                            ,I001.PRE_IND_BCD            --기존양품바코드
                            ,I001.PACK_LABEL_TYPE        --포장 라벨 유형(01:내수-페이퍼, 02:내수-스티커, 03:수출-페이퍼, 04:수출-스티커)
                            ,I001.STK_FLAG               --재고구분
                            ,I001.OLD_UNIT               
                            ,I001.OLD_QTY                
                            ,I001.MR_WH_YN               --밀롤창고에서 출고여부
                            ,I001.RET_REQ_QTY			 --반납요청수량
                       FROM TB_INV001 I001  --공정재고
                           ,TB_WRK002 W002  --PS실적
                           ,TB_MAS003 M003  --저장위치
                      WHERE I001.IND_BCD = W002.IND_BCD(+)
                        AND I001.WERKS = M003.WERKS(+)
                        AND I001.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                 ';
                                                 
            IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN                   --개별바코드
                V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';            				      
            END IF;
        
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;
        
    ELSIF P_TYPE = 'SAVE' THEN                  --저장
        /*SELECT count(1) INTO V_CNT 
          FROM TB_INV001_1031
         WHERE IND_BCD = V_IND_BCD;
        
        IF V_CNT > 0 THEN
            P_SUCCESS   := 'N';
            P_ERR_MSG   := V_IND_BCD || '는 이미 재고실사 등록한 바코드입니다.';
            ROLLBACK;
            RETURN;
        ELSE
            INSERT INTO TB_INV001_1031(WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO, MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, PRD_NO
                                   , IN_MR_YN, STCK_KY, PRFM_DT, PRD_DT, UNIT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY
                                   , EA_QTY, ROLLCNT, WGT, SUPY_CD, LOT_NUM, STCK_STA, VBELN, POSNR, KUNNR, FNL_JDGM, MSRM_DATE, PRC_SEQNO, INSPR_ID
                                   , CHK_PP_YN, CHK_PP_DATE, CHK_PP_ID, CHK_QC_YN, CHK_QC_DATE, CHK_QC_ID, DOC_NO, DOC_SEQNO, WDOC_NO, WDOC_SEQNO, DLFL
                                   , REGDATE, REGID, UPDDATE, UPDID, RUN_STA, APVR_STA, CFRM_ID, CFRM_DATE, BS_WGT, CON_TYPE, PACK_TYPE, DISPO_DT
                                   , DISPO_QTY, SDOC_NO, SDOC_SEQNO, DOC_ID, SND_MSG, UCFMTY_AMT, UCFMTY_FLG, MER_STOCK_QTY, PRE_IND_BCD, PACK_LABEL_TYPE
                                   , STK_FLAG, OLD_UNIT, OLD_QTY, MR_WH_YN, RET_REQ_QTY, ORDER_DLFL)
                            SELECT I001.WERKS, I001.STOR_LOC_CD, I001.IND_BCD, I001.MATNR, I001.LOC_CD, I001.LOT_NO, I001.MACH_CD, I001.MACHINE, I001.WRK_ORDR_NO, I001.WRK_ORDR_SEQNO, I001.ORDER_NO, I001.PRD_NO
                                 , I001.IN_MR_YN, I001.STCK_KY, I001.PRFM_DT, I001.PRD_DT, I001.UNIT, DECODE(NVL(I001.STCK_QTY, 0), 0, W002.PRFM_QTY, I001.STCK_QTY), I001.PLT_QTY, I001.BOX_QTY, I001.BAG_QTY
                                 , I001.EA_QTY, I001.ROLLCNT, I001.WGT, I001.SUPY_CD, I001.LOT_NUM, I001.STCK_STA, I001.VBELN, I001.POSNR, I001.KUNNR, I001.FNL_JDGM, I001.MSRM_DATE, I001.PRC_SEQNO, I001.INSPR_ID
                                 , I001.CHK_PP_YN, I001.CHK_PP_DATE, I001.CHK_PP_ID, I001.CHK_QC_YN, I001.CHK_QC_DATE, I001.CHK_QC_ID, I001.DOC_NO, I001.DOC_SEQNO, I001.WDOC_NO, I001.WDOC_SEQNO, I001.DLFL
                                 , I001.REGDATE, I001.REGID, I001.UPDDATE, I001.UPDID, I001.RUN_STA, I001.APVR_STA, I001.CFRM_ID, I001.CFRM_DATE, I001.BS_WGT, I001.CON_TYPE, I001.PACK_TYPE, I001.DISPO_DT
                                 , I001.DISPO_QTY, I001.SDOC_NO, I001.SDOC_SEQNO, I001.DOC_ID, I001.SND_MSG, I001.UCFMTY_AMT, I001.UCFMTY_FLG, I001.MER_STOCK_QTY, I001.PRE_IND_BCD, I001.PACK_LABEL_TYPE
                                 , I001.STK_FLAG, I001.OLD_UNIT, I001.OLD_QTY, I001.MR_WH_YN, I001.RET_REQ_QTY, CASE WHEN I001.IND_BCD LIKE '%C%' THEN DECODE(NVL(S017.USE_YN, 'N'), 'Y', 'Y', 'N') END  
                             FROM TB_INV001 I001  --공정재고
                                 ,TB_WRK002 W002  --PS실적
                                 ,TB_SCH017 S017  --재단작업지시
                            WHERE I001.IND_BCD = W002.IND_BCD(+)
                              AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                              AND I001.IND_BCD = V_IND_BCD;
        END IF;*/
    
    	SELECT COUNT(*) INTO V_CNT
    	  FROM TEMP_1214 t 
    	 WHERE IND_BCD = V_IND_BCD;
    	
    	IF V_CNT > 0 THEN
            P_SUCCESS   := 'N';
            P_ERR_MSG   := V_IND_BCD || '는 이미 재고실사 등록한 바코드입니다.';
            ROLLBACK;
            RETURN;
        ELSE
        	INSERT INTO TEMP_1214(IND_BCD, REGDATE, REGID)
        					VALUES(V_IND_BCD, SYSDATE, V_SESS_USER_ID);
        END IF;
	END IF;

	P_SUCCESS := 'Y';
    COMMIT;

--	EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--    -- 에러 내역 SET
--    P_SUCCESS           := 'N';
--    
--    --에러메시지는 사용자에러 호출 위치에서 지정해야 함.
--    --E_SQL_ERR_CD        := SQLCODE;
--		--E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';        
--
--		ROLLBACK;
--		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);		
--
--	WHEN OTHERS THEN
--		P_SUCCESS			:= 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--		ROLLBACK;
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
