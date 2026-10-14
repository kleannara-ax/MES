
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_PKG_LOG" SP_AUTO_PKG_LOG
(
    p_log_txt       IN CLOB,          -- 그룹지어 넘어온 전체 로그 텍스트
    p_ind_bcd       IN VARCHAR2,      -- 개별 바코드
    p_rmk           IN VARCHAR2       -- 비고(RMK)
) AS

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO TB_AUTO_PKG_LOG (
      LOG_SEQ,
      LOG_REG_DATE,
      LOG_TXT,
      IND_BCD,
      RMK
  )
  VALUES (
      SEQ_AUTO_PKG_LOG.NEXTVAL,     -- 시퀀스 직접 사용
      SYSTIMESTAMP,            -- 밀리초까지 기록하기 위해 TIMESTAMP 사용
      p_log_txt,
      p_ind_bcd,
      p_rmk
  );

  COMMIT; -- 로그 기록 확정

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK; -- 로그 기록 중 에러 발생 시 로그 트랜잭션만 취소
    -- 필요한 경우 여기에 에러 메시지를 DBMS_OUTPUT 등으로 출력할 수 있습니다.
END ;
/
