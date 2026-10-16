/*==============================================================================
 * WRK55 화장지 RFC 전송 로그 - 테이블 / 시퀀스 DDL
 *
 *  TB_WRK055   : 로그 헤더  (프로시저 1회 RFC 파라미터 생성 = 1건)
 *                 어떤 프로시저가, 어떤 IF_ID / RFC 로, 어떤 문서번호를 보냈는지
 *  TB_WRK055_D : 로그 상세  (RFC 로 넘어가는 파라미터 1행 = 1건)
 *                 FN_IF_QUERY 결과(=실제 RFC IT_DATA) 원문 JSON + 수량 분류
 *
 *  ※ 적용 순서 : 1) 본 DDL  2) PKG_WRK055.sql  3) 대상 프로시저  4) SP_WRK55_S01.sql
 *==============================================================================*/

CREATE SEQUENCE KNRAMES.SEQ_WRK055 START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE KNRAMES.TB_WRK055 (
    LOG_SEQ     NUMBER          NOT NULL,       -- 로그 순번
    LOG_DATE    DATE            DEFAULT SYSDATE NOT NULL, -- 로그 일시
    PRG_NM      VARCHAR2(100),                  -- 로그를 남긴 프로시저명
    WERKS       VARCHAR2(4),                    -- 플랜트
    IF_ID       VARCHAR2(30),                   -- 인터페이스 ID (TB_ITFMA.IFID)
    RFCFN       VARCHAR2(200),                  -- RFC 함수명   (TB_ITFMA.RFCFN)
    IFTBL       VARCHAR2(30),                   -- I/F 테이블   (TB_ITFMA.IFTBL)
    SYSFR       VARCHAR2(10),                   -- 송신 시스템
    SYSTO       VARCHAR2(10),                   -- 수신 시스템
    DOC_NO      VARCHAR2(400),                  -- MES 문서번호
    ROW_CNT     NUMBER,                         -- RFC 파라미터 행 수
    LOG_STA     VARCHAR2(1),                    -- S:정상, W:파라미터 없음, E:로그 처리 오류
    LOG_MSG     VARCHAR2(4000),                 -- 로그 처리 메시지
    IF_SQL      VARCHAR2(4000),                 -- FN_IF_QUERY 로 생성된 조회 SQL
    REGID       VARCHAR2(20),
    REGDATE     DATE            DEFAULT SYSDATE,
    CONSTRAINT PK_TB_WRK055 PRIMARY KEY (LOG_SEQ)
);

CREATE INDEX KNRAMES.IX_TB_WRK055_01 ON KNRAMES.TB_WRK055 (LOG_DATE);
CREATE INDEX KNRAMES.IX_TB_WRK055_02 ON KNRAMES.TB_WRK055 (DOC_NO);

COMMENT ON TABLE  KNRAMES.TB_WRK055          IS '화장지 RFC 전송 로그(헤더)';
COMMENT ON COLUMN KNRAMES.TB_WRK055.PRG_NM   IS '로그를 남긴 프로시저명';
COMMENT ON COLUMN KNRAMES.TB_WRK055.IF_ID    IS '인터페이스 ID';
COMMENT ON COLUMN KNRAMES.TB_WRK055.RFCFN    IS 'RFC 함수명';
COMMENT ON COLUMN KNRAMES.TB_WRK055.LOG_STA  IS 'S:정상 W:파라미터없음 E:로그오류';

CREATE TABLE KNRAMES.TB_WRK055_D (
    LOG_SEQ     NUMBER          NOT NULL,
    ROW_SEQ     NUMBER          NOT NULL,       -- 파라미터 행 순번
    MDOCNO      VARCHAR2(30),                   -- MES 문서번호
    MDOCSEQ     VARCHAR2(10),                   -- MES 문서순번
    AUFNR       VARCHAR2(20),                   -- 오더번호
    MATNR       VARCHAR2(40),                   -- 자재코드
    LOTNO       VARCHAR2(30),                   -- LOT (CHARG / LOTNO)
    IND_BCD     VARCHAR2(30),                   -- 개별바코드 (파라미터에 있는 경우)
    BUDAT       VARCHAR2(10),                   -- 전기/실적일자
    QTY_DIV     VARCHAR2(10),                   -- PRFM, PRFM_CNL, USE, USE_CNL, DISPO, DISPO_CNL, MOVE, WMS_IN, RMD, ETC
    PRFM_QTY    NUMBER,                         -- 생산량
    USE_QTY     NUMBER,                         -- 사용량 (취소는 음수)
    DISPO_QTY   NUMBER,                         -- 폐품   (취소는 음수)
    RMD_QTY     NUMBER,                         -- 잔량
    UNIT        VARCHAR2(10),                   -- 단위
    PARAM_JSON  CLOB,                           -- RFC 파라미터 행 원문 (컬럼명:값)
    CONSTRAINT PK_TB_WRK055_D PRIMARY KEY (LOG_SEQ, ROW_SEQ)
);

CREATE INDEX KNRAMES.IX_TB_WRK055_D_01 ON KNRAMES.TB_WRK055_D (MDOCNO, MDOCSEQ);
CREATE INDEX KNRAMES.IX_TB_WRK055_D_02 ON KNRAMES.TB_WRK055_D (LOTNO);
CREATE INDEX KNRAMES.IX_TB_WRK055_D_03 ON KNRAMES.TB_WRK055_D (MATNR);

COMMENT ON TABLE  KNRAMES.TB_WRK055_D            IS '화장지 RFC 전송 로그(파라미터 행)';
COMMENT ON COLUMN KNRAMES.TB_WRK055_D.QTY_DIV    IS 'PRFM/PRFM_CNL/USE/USE_CNL/DISPO/DISPO_CNL/MOVE/WMS_IN/RMD/ETC';
COMMENT ON COLUMN KNRAMES.TB_WRK055_D.PARAM_JSON IS 'RFC 파라미터 행 원문 JSON';

/* 롤백용
DROP TABLE KNRAMES.TB_WRK055_D;
DROP TABLE KNRAMES.TB_WRK055;
DROP SEQUENCE KNRAMES.SEQ_WRK055;
*/
