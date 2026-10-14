--------------------------------------------------------
--  DDL for Function FN_NON_ACT_TM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_NON_ACT_TM" 
(
    P_STR_DATE	IN DATE,
    P_END_DATE	IN DATE,
    P_MACH_CD	IN VARCHAR2
)
    RETURN NUMBER IS
/*=============================================================================*
 * FUNCTION NAME: FN_NON_ACT_TM
 *   1)INPUT VALUE
 *      P_STR_DATE: 시작날짜
 *      P_END_DATE: 종료날짜
 *      P_MACH_CD: 확인 설비
 *   2)OUTPUT VALUE
 *      R_CD_NM: 비가동 시간
 * CREATE DATE  : 2022/10/04
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/10/04    1.0.0   김기연        Initial Version
 * 2022/10/06    1.0.0   김기연        호기별 비가동 연계로 인한 비가동 이력 통합
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    RTN_TM		NUMBER; --비가동 시간(반환)
    TM_MID		NUMBER;	--중간시간
    TM_BFE		NUMBER;	--이전시간
    TM_AFT		NUMBER;	--이후시간
BEGIN
    --결과값 초기화
    RTN_TM := 0;

   	--범위내 포함된 비가동 시간 합계
    SELECT CEIL(SUM(END_DATE - STR_DATE) * 24 * 60)
      INTO TM_MID
	  FROM TB_WRK003
	 WHERE 1=1
	   AND MACH_CD = P_MACH_CD
	   --AND IN_OUT  != 'O'
	   AND STR_DATE >= P_STR_DATE
	   AND END_DATE <= P_END_DATE;
	  
	--이전 시간대의 비가동에 따른 비가동 시간 합계
	SELECT CEIL(SUM(END_DATE - P_STR_DATE) * 24 * 60)
      INTO TM_BFE
	  FROM TB_WRK003
 	 WHERE 1=1
	   AND MACH_CD = P_MACH_CD
	   --AND IN_OUT  != 'O'
	   AND STR_DATE < P_STR_DATE
	   AND END_DATE >= P_STR_DATE
	   AND END_DATE <= P_END_DATE;
	--이후 시간대의 비가동에 따른 비가동 시간 합계
	SELECT CEIL(SUM(P_END_DATE - STR_DATE) * 24 * 60)
	  INTO TM_AFT
	  FROM TB_WRK003
	 WHERE 1=1
	   AND MACH_CD = P_MACH_CD
	   --AND IN_OUT != 'O'
	   AND END_DATE > P_END_DATE
	   AND STR_DATE >= P_STR_DATE
	   AND STR_DATE <= P_END_DATE;

	--비가동 시간 합계
	RTN_TM := NVL(TM_MID,0) + NVL(TM_BFE,0) + NVL(TM_AFT,0);

    RETURN RTN_TM;
    
END;

/
