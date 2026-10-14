
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_SND_WRK_ORDR_NO" SP_AUTO_SND_WRK_ORDR_NO
(
	P_WERKS   IN VARCHAR2,
	P_MACH_CD IN VARCHAR2,
	CUR_1       OUT SYS_REFCURSOR
)

/*==============================================================================
 * PROGRAM ID    : SP_AUTO_SND_WRK_ORDR_NO{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 작업지시정보 전송 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 오토라벨러에 작업지시정보를 전달한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 백우종{최초 작성자 명 기술}
 * CREATE DATE   : {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   백우종         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/

AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_AUTO_SND_WRK_ORDR_NO';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_DATE DATE := SYSDATE;
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);
BEGIN
	BEGIN
		BEGIN
		    --현재 작업지시 조회
		    OPEN CUR_1 FOR
		    SELECT S012.PRD_REQ_DT         --생산지시일
		         , W011.WRK_ORDR_NO         --작업지시
		         , W011.WRK_ORDR_SEQNO      --작업지시 순번
		         , S012.ORDER_NO            --생산오더
		         , S012.MATNR               --자재코드
		         , M001.MATNR_NM            --자재명
		         , M001.MATNR_SPEC          --규격
		         , M001.PCODE               --지종
		         , M001.PCODE_NM            --지종명
		         , S012.SPEC                --지시규격
		         , S012.WRK_ORDR_QTY        --계획수량
		         , S012.PRFM_QTY            --실적수량
		         , S012.UNIT                --단위
		         , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S012.UNIT, 'PAL', S012.WRK_ORDR_QTY)) AS PLTORDR --계획팔레트
		         , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S012.UNIT, 'BOX', S012.WRK_ORDR_QTY)) AS BOXORDR --계획박스
		         , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S012.UNIT, 'BAG', S012.WRK_ORDR_QTY)) AS BAGORDR --계획폴리백
		         , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S012.UNIT, 'EA', S012.WRK_ORDR_QTY)) AS EAORDR --계획개수
		         , CEIL(W001.PLT) AS PLTQTY       --실적(팔레트)
		         , CEIL(W001.BOX) AS BOXQTY       --실적(팔레트)
		         , CEIL(W001.BAG) AS BAGQTY       --실적(팔레트)
		         , CEIL(W001.EA) AS EAQTY       --실적(팔레트)
		         , S012.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
		         , W011.MACH_STA            --가동여부
		         , W011.EMPLY_NO AS USERID
		         , W011.LOT_NO
		         , CMC.CDESC1 AS PART_DIV
		         , M001.KAN_NO
	    		 , FN_CHG_UNIT(M001.MATNR, S012.WERKS, 'BAG', 'EA', 1) || 'x' || FN_CHG_UNIT(M001.MATNR, S012.WERKS, 'BOX', 'BAG', 1) AS BASIC_UNIT
	    		 , FN_CHG_UNIT(M001.MATNR, S012.WERKS, 'PAL', 'BOX', 1) AS PALLET_UNIT
	    		 , FN_CHG_UNIT(M001.MATNR, S012.WERKS, 'PAL', 'BOX', 1) AS RCV_QTY
	    		 , FN_CHG_UNIT(M001.MATNR, S012.WERKS, 'BOX', 'BAG', 1) AS BAG_QTY
		    FROM TB_WRK011 W011,            --작업장 현황
		         TB_SCH012 S012,            --화장지 가공기 작업지시
		         TB_MAS001 M001,            --자재정보
		         (SELECT WERKS, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, MAX(PRD_STR_DATE) AS WRK_STR_DATE, MAX(PRD_END_DATE) AS WRK_END_DATE
		               , SUM(W001.PLT_QTY) AS PLT, SUM(W001.BOX_QTY) AS BOX, SUM(W001.BAG_QTY) AS BAG, SUM(W001.EA_QTY) AS EA 
		            FROM TB_WRK001 W001
		           WHERE MACH_CD = P_MACH_CD
		             AND W001.PRFM_GTHR_YN = 'Y'
		           GROUP BY WERKS, MACH_CD, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO) W001,  --생산실적
		         CMCDV CMC
		    WHERE 1=1 
		    AND W011.WERKS = S012.WERKS(+)
		    AND W011.WRK_ORDR_NO = S012.WRK_ORDR_NO(+)
		    AND W011.WRK_ORDR_SEQNO = S012.WRK_ORDR_SEQNO(+)
		    AND W011.WERKS = M001.WERKS(+)
		    AND W011.MATNR = M001.MATNR(+)
		    AND W011.WERKS = W001.WERKS(+)
		    AND W011.WRK_ORDR_NO = W001.WRK_ORDR_NO(+)
		    AND W011.WRK_ORDR_SEQNO = W001.WRK_ORDR_SEQNO(+)
		    AND M001.PART_DIV = CMC.CMCDVL
		    AND CMC.CMCDKY = 'PART_DIV'
		    AND W011.MACH_CD = P_MACH_CD
		    AND W011.IN_OUT = 'I';
		END;
	    --예외처리(catch)
	    EXCEPTION
	    WHEN E_EXCEPTION_USER THEN
	        -- 에러 내역 SET
	        E_SQL_ERR_CD        := SQLCODE;
	        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
	
	        ROLLBACK;
	        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
	
--	        RS_CODE := 'E';
--	        RS_MSG  := SQLERRM;
	        RETURN;
	    WHEN OTHERS THEN
	        E_SQL_ERR_CD        := SQLCODE;
	        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
	
	        ROLLBACK;
	        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
	
--	        RS_CODE := 'E';
--	        RS_MSG  := SQLERRM;
	        RETURN;
	    --예외처리 종료
	END;
END;
/
