--------------------------------------------------------
--  DDL for Trigger SZT_MSTMENUGL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "KNRAMES"."SZT_MSTMENUGL_INS" 

BEFORE INSERT OR UPDATE OR DELETE
ON KNRAMES.MSTMENUGL
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
  
    v_sysdat    VARCHAR2(8) := TO_CHAR(SYSDATE,'YYYYMMDD');
    v_systim    VARCHAR2(6) := TO_CHAR(SYSDATE,'HH24MISS');
    v_errnum    number;
    v_errmsg    VARCHAR2(1000);

BEGIN
--    INSERT INTO TEST(
--     DATA
--    )VALUES(
--        v_sysdat ||', '|| v_systim ||', '|| 
--             'MNNW' ||', '|| ' ' ||', '|| ' '
--           ||', '|| '신규 메뉴 등록 [' || :new.MENUID || ']'
--    );

    --[21.08.10] junghyojin : 권한(메뉴/MN)로그
    IF INSERTING THEN
        INSERT INTO SYSLG
        (
            LOGDAT, LOGTIM, LOGUSR
          , LOGTYP, LOGIPA, PROGID
          , REMARK
          , CREDAT, CRETIM, CREUSR
          , LMODAT, LMOTIM, LMOUSR
          , INDBZL, INDARC, UPDCHK 
        )
        VALUES(
            v_sysdat, v_systim, :new.CREATEUSER
          , 'MNNW', ' ', ' '
          , '신규 메뉴 등록 [' || :new.MENUID || ']'
          , v_sysdat, v_systim, :new.CREATEUSER
          , v_sysdat, v_systim, :new.CREATEUSER
          , ' ', ' ', 0
        );
    ELSIF UPDATING THEN
        INSERT INTO SYSLG
        (
            LOGDAT, LOGTIM, LOGUSR
          , LOGTYP, LOGIPA, PROGID
          , REMARK
          , CREDAT, CRETIM, CREUSR
          , LMODAT, LMOTIM, LMOUSR
          , INDBZL, INDARC, UPDCHK 
        )
        VALUES(
            v_sysdat, v_systim, :new.CREATEUSER
          , 'MNUP', ' ', ' '
          , '메뉴 변경  [' || :new.MENUID || ']'
          , v_sysdat, v_systim, :new.CREATEUSER
          , v_sysdat, v_systim, :new.CREATEUSER
          , ' ', ' ', 0
        );
    ELSIF DELETING THEN
        INSERT INTO SYSLG
        (
            LOGDAT, LOGTIM, LOGUSR
          , LOGTYP, LOGIPA, PROGID
          , REMARK
          , CREDAT, CRETIM, CREUSR
          , LMODAT, LMOTIM, LMOUSR
          , INDBZL, INDARC, UPDCHK 
        )
        VALUES(
            v_sysdat, v_systim, :old.CREATEUSER
          , 'MNDL', ' ', ' '
          , '메뉴 삭제  [' || :old.MENUID || ']'
          , v_sysdat, v_systim, :old.CREATEUSER
          , v_sysdat, v_systim, :old.CREATEUSER
          , ' ', ' ', 0
        );
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_errnum := -20011;
        v_errmsg := 'SMSERR:DUP)-ORA'||ltrim(rtrim(to_char(sqlcode,'00000')))||' : '||substr(sqlerrm,1,200);
        RAISE_APPLICATION_ERROR(v_errnum, v_errmsg);
        RETURN;
    WHEN OTHERS THEN
        v_errnum := -20012;
        v_errmsg := 'SMSERR:OTHS)-ORA'||ltrim(rtrim(to_char(sqlcode,'00000')))||' : '||substr(sqlerrm,1,200);
        RAISE_APPLICATION_ERROR(v_errnum, v_errmsg);
        RETURN;
END;

/
ALTER TRIGGER "KNRAMES"."SZT_MSTMENUGL_INS" DISABLE;
