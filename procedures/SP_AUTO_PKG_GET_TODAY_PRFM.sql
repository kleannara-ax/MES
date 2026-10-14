
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_PKG_GET_TODAY_PRFM" (
    CUR      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_AUTO_PKG_GET_TODAY_PRFM
 * PROGRAM NAME  : 오늘자 실적갯수 및 총 중량
 * VERSION       : 1.0.0
 * DESCRIPTION   : 원지포장자동화 HMI 화면에서 사용
 *
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2026/02/15
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2026/02/15    1.0.0   김지언         Initial Version
 *==============================================================================
 *  관련 테이블
 *        - [TB_AUTO_PKG_PRFM] : ( R  ) 원지포장실적테이블
 *=============================================================================*/
AS
BEGIN
    OPEN CUR FOR
        select WRAP_CD          AS WRAP_CD
             , count(*)         AS PRFM_CNT
             , sum(PRFM_QTY)    AS PRFM_WGT
        from TB_AUTO_PKG_PRFM
        where 1=1
          and REGDATE >= TRUNC(SYSDATE - 7/24) + 7/24
          and REGDATE <  TRUNC(SYSDATE - 7/24) + 1 + 7/24
--             and PRFM_DT = FN_RECDATE(SYSDATE)
        group by WRAP_CD
        order by WRAP_CD;
END;
/
