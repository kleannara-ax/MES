--------------------------------------------------------
--  DDL for Trigger SZT_USRMA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "KNRAMES"."SZT_USRMA_INS" 
BEFORE INSERT OR UPDATE OR DELETE              
ON KNRAMES.USRMA                
REFERENCING NEW AS NEW OLD AS OLD               
FOR EACH ROW
DECLARE                                   
  v_VeriCh     VARCHAR2(10);                                   
  v_VeriNu     number(20,3);                                   
  v_sysdat     VARCHAR2(8) := TO_CHAR(SYSDATE,'YYYYMMDD');                                   
  v_systim     VARCHAR2(6) := TO_CHAR(SYSDATE,'HH24MISS');                                   
  v_errnum     number;                                   
  v_errmsg     VARCHAR2(1000);                                   
  v_FuncRet    VARCHAR2(3);                                   
  v_FuncMsg    VARCHAR2(255);                                   
  v_updchk     number(5);                                        
BEGIN


  IF :new.indbzl <> ' ' THEN                                   
    :new.indbzl := ' ';                                   
    RETURN;                                   
  END IF;               

  IF     :NEW.DELMAK = '1' THEN                   
         :NEW.DELMAK := 'V';                    
  ELSIF  :NEW.DELMAK = ' ' THEN                  
         :NEW.DELMAK := ' ';                     
  END IF;       


    --[21.08.10] junghyojin : 권한(사용자/US)로그 
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
            v_sysdat, v_systim, :new.LMOUSR
          , 'USNW', ' ', ' '
          , '신규 사용자ID 생성 [' || :new.USERID || ']'
          , v_sysdat, v_systim, :new.LMOUSR
          , v_sysdat, v_systim, :new.LMOUSR
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
            v_sysdat, v_systim, :new.LMOUSR
          , 'USUP', ' ', ' '
          , '사용자ID 정보 변경  [' || :new.USERID || ']'
          , v_sysdat, v_systim, :new.LMOUSR
          , v_sysdat, v_systim, :new.LMOUSR
          , ' ', ' ', 0
        );

        IF :old.DELMAK != :new.DELMAK THEN
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
                v_sysdat, v_systim, :new.LMOUSR
              , 'USUP', ' ', ' '
              , '사용자ID 정보 변경 [' || :new.USERID || '] 활성화 변경 [' || CASE WHEN :new.DELMAK = ' ' THEN '활성화'
                                                                                   ELSE '비활성화'
                                                                              END || ']'
              , v_sysdat, v_systim, :new.LMOUSR
              , v_sysdat, v_systim, :new.LMOUSR
              , ' ', ' ', 0
            );
        END IF;

        IF :old.MENUKY != :new.MENUKY THEN
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
                v_sysdat, v_systim, :new.LMOUSR
              , 'USMN', ' ', ' '
              , '사용자ID 정보 변경 [' || :new.USERID || '] WEB 메뉴 변경 [' || :old.MENUKY || ' -> ' || :NEW.MENUKY || ']'
              , v_sysdat, v_systim, :new.LMOUSR
              , v_sysdat, v_systim, :new.LMOUSR
              , ' ', ' ', 0
            );
        END IF;

        IF :old.PDAMKY != :new.PDAMKY THEN
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
                v_sysdat, v_systim, :new.LMOUSR
              , 'USMN', ' ', ' '
              , '사용자ID 정보 변경 [' || :new.USERID || '] PDA 메뉴 변경 [' || :old.PDAMKY || ' -> ' || :NEW.PDAMKY || ']'
              , v_sysdat, v_systim, :new.LMOUSR
              , v_sysdat, v_systim, :new.LMOUSR
              , ' ', ' ', 0
            );
        END IF;
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
            v_sysdat, v_systim, :old.LMOUSR
          , 'USDL', ' ', ' '
          , '사용자ID 삭제  [' || :old.USERID || ']'
          , v_sysdat, v_systim, :old.LMOUSR
          , v_sysdat, v_systim, :old.LMOUSR
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
ALTER TRIGGER "KNRAMES"."SZT_USRMA_INS" DISABLE;
