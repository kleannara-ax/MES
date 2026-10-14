/*
 * Oracle SQL Developer: 아래 두 값만 변경한 후 F5(스크립트 실행)
 * 문자열 따옴표는 여기에서만 사용한다.
 */
DEFINE MATNR = '1400092'
DEFINE LOT_NO = '2512140006'

PROMPT ============================================================
PROMPT 1. 불출/반납 확정 이력 - TB_INV007
PROMPT ============================================================

SELECT *
  FROM TB_INV007
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY REGDATE DESC;


PROMPT ============================================================
PROMPT 2. 불출 요청(MES -> WMS) - TB_IFSWM002
PROMPT ============================================================

SELECT *
  FROM TB_IFSWM002
 WHERE MATNR = '&MATNR'
   /* 일반 불출요청은 WMS가 배치/바코드를 배정하기 전이라 LOT_NO가 NULL일 수 있음 */
   AND (LOT_NO = '&LOT_NO' OR LOT_NO IS NULL)
 ORDER BY IF_GET_DATE DESC;


PROMPT ============================================================
PROMPT 3. 불출 응답(WMS -> MES) - TB_IFRWM002
PROMPT ============================================================

SELECT *
  FROM TB_IFRWM002
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY IF_GET_DATE DESC;


PROMPT ============================================================
PROMPT 4. 반납 요청(MES -> WMS) - TB_IFSWM004
PROMPT ============================================================

SELECT *
  FROM TB_IFSWM004
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY IF_GET_DATE DESC;


PROMPT ============================================================
PROMPT 5. 반납 응답(WMS -> MES) - TB_IFRWM005
PROMPT ============================================================

SELECT *
  FROM TB_IFRWM005
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY IF_GET_DATE DESC;


PROMPT ============================================================
PROMPT 6. 생산 사용 이력 - TB_INV010
PROMPT ============================================================

SELECT *
  FROM TB_INV010
 WHERE MATNR_M = '&MATNR'
   AND LOT_NO_M = '&LOT_NO'
 ORDER BY REGDATE DESC;


PROMPT ============================================================
PROMPT 7. MES 창고 현재재고 - TB_INV001
PROMPT ============================================================

SELECT *
  FROM TB_INV001
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY IND_BCD;


PROMPT ============================================================
PROMPT 8. MES 생산 투입재고 - TB_INV003
PROMPT ============================================================

SELECT *
  FROM TB_INV003
 WHERE MATNR = '&MATNR'
   AND LOT_NO = '&LOT_NO'
 ORDER BY IND_BCD, SEQNO;


UNDEFINE MATNR
UNDEFINE LOT_NO
