--------------------------------------------------------
--  DDL for Procedure SP_TEMP_NOT_USE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_TEMP_NOT_USE" 
(
     P_TABLE_NAME   IN VARCHAR2
    ,P_LIST_ALL     IN CLOB
    ,P_LIST_PK      IN CLOB
    ,P_ACTION_TYPE  IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
AS 
    V_DATE            DATE := SYSDATE;
    V_SQL             VARCHAR2(4000);    
    V_TABLE_NAME      VARCHAR2(100);
    V_USER_ID         VARCHAR2(100);
    V_PK_COUNT        VARCHAR2(100);
    V_ALL_PARSE_LIST  JSON_OBJECT_T;
    V_PK_PARSE_LIST   JSON_OBJECT_T;
    V_ARR_LIST        JSON_ARRAY_T;
    V_KEY_VALUE_LIST  JSON_KEY_LIST;
    V_OBJECT          JSON_OBJECT_T;
    
    V_SELECT          VARCHAR2(100);
    V_SELECT_CNT      VARCHAR2(100);
    V_INSERT          VARCHAR2(100);
    V_UPDATE          VARCHAR2(100);
    V_DELETE          VARCHAR2(100);
    V_VALUES          VARCHAR2(100);
    V_WHERE           VARCHAR2(100);
    V_AND             VARCHAR2(100);
    V_SET             VARCHAR2(100);
    V_EQUAL           VARCHAR2(100);
    V_COMMA           VARCHAR2(100);
    V_OPEN            VARCHAR2(40);
    V_CLOSE           VARCHAR2(40);
    V_TEXT_FORMAT     VARCHAR2(40);
    V_COLUMNS         VARCHAR2(1000);
    V_INSERT_VALUES   VARCHAR2(2000);
    V_UPDATE_SET_VALUES VARCHAR2(2000);
    V_WHERE_VALUES    VARCHAR2(2000);
    V_DELETE_VALUES   VARCHAR2(2000);
    V_COUNT           VARCHAR2(40);
    V_ACTIONTYPE      VARCHAR2(100);
BEGIN
    SELECT SYSDATE INTO V_DATE FROM DUAL;
    V_ACTIONTYPE := P_ACTION_TYPE;
    
    V_SELECT      := ' SELECT * FROM ';
    V_SELECT_CNT  := ' SELECT COUNT(0) INTO ';
    V_INSERT      := ' INSERT INTO ';
    V_UPDATE      := ' UPDATE ';
    V_DELETE      := ' DELETE FROM ';
    V_VALUES      := ' VALUES ';
    V_WHERE       := ' WHERE ';
    V_SET         := ' SET ';
    V_AND         := ' AND ';
    V_EQUAL       := ' = ';
    V_COMMA       := ',';
    V_OPEN        := '( ';
    V_CLOSE       := ' )';
    V_TEXT_FORMAT := '''';
    V_COUNT       := 'V_COUNT';
    
    IF V_ACTIONTYPE = 'TABLE_LIST' THEN
        V_SQL := ' SELECT A.TABLE_NAME COL, A.TABLE_NAME VALUE  FROM ALL_IND_COLUMNS A WHERE 1 = 1 AND A.TABLE_OWNER = ''KNRAMES'' ';
        V_SQL := V_SQL || ' ORDER BY A.TABLE_NAME ';
        OPEN CUR_1 FOR
            V_SQL;
        RETURN;
    END IF;
    
    IF V_ACTIONTYPE = 'COLUMN_LIST' THEN
        V_SQL := ' SELECT B.PK,A.COLUMN_NAME, A.DATA_TYPE,A.DATA_LENGTH,A.COLUMN_ID, '''' AS COLUMN_VALUE FROM ( ';
        V_SQL := V_SQL || ' SELECT A.TABLE_NAME, A.COLUMN_NAME, A.DATA_TYPE,A.DATA_LENGTH,A.COLUMN_ID FROM ALL_TAB_COLUMNS A WHERE 1 = 1 ';
        V_SQL := V_SQL || ' AND A.OWNER = ''KNRAMES'' AND A.TABLE_NAME = ' || V_TEXT_FORMAT || P_TABLE_NAME || V_TEXT_FORMAT || ' )A, ( ';
        V_SQL := V_SQL || ' SELECT A.TABLE_NAME, A.COLUMN_NAME, ''PK'' AS PK FROM ALL_IND_COLUMNS A WHERE 1 = 1 ';
        V_SQL := V_SQL || ' AND A.TABLE_OWNER = ''KNRAMES'' AND A.TABLE_NAME = ' || V_TEXT_FORMAT || P_TABLE_NAME || V_TEXT_FORMAT || ' )B ';
        V_SQL := V_SQL || ' WHERE A.COLUMN_NAME = B.COLUMN_NAME(+) ORDER BY A.COLUMN_ID ';
        OPEN CUR_1 FOR
            V_SQL;
        RETURN;
    END IF;
    
    IF V_ACTIONTYPE = 'RA' THEN
        V_SQL := V_SELECT || P_TABLE_NAME ;
        OPEN CUR_1 FOR
            V_SQL;
        RETURN;
    END IF;
    
    IF V_ACTIONTYPE = 'CU' THEN
        V_PK_PARSE_LIST    := JSON_OBJECT_T.PARSE(P_LIST_PK); 
        V_ARR_LIST         := V_PK_PARSE_LIST.GET_ARRAY('LIST');
    
        FOR i IN 0..V_ARR_LIST.GET_SIZE-1 LOOP
            V_OBJECT         := TREAT(V_ARR_LIST.GET(i) AS JSON_OBJECT_T);
            V_OBJECT         := TREAT(V_OBJECT.GET('MAP') AS JSON_OBJECT_T);
            V_KEY_VALUE_LIST := V_OBJECT.GET_KEYS;
             
            FOR j IN 1 .. V_KEY_VALUE_LIST.COUNT 
            LOOP
                V_WHERE_VALUES := V_WHERE_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(V_SQL);
        V_SQL := V_SELECT_CNT || V_COUNT || V_TABLE_NAME || V_WHERE || V_WHERE_VALUES;
        IF V_COUNT > 0 THEN
          V_ACTIONTYPE := 'U';
        ELSE
          V_ACTIONTYPE := 'C';
        END IF;
    END IF;
    
    V_ALL_PARSE_LIST   := JSON_OBJECT_T.PARSE(P_LIST_ALL); 
    V_TABLE_NAME       := V_ALL_PARSE_LIST.GET_STRING('TABLE_NAME'); 
    V_USER_ID          := V_ALL_PARSE_LIST.GET_STRING('USER_ID');
    V_PK_COUNT         := V_ALL_PARSE_LIST.GET_STRING('PK_COUNT');
    V_ARR_LIST         := V_ALL_PARSE_LIST.GET_ARRAY('LIST');
        
    IF V_ACTIONTYPE = 'R' THEN
        FOR i IN 0..V_ARR_LIST.GET_SIZE-1 LOOP
            V_OBJECT       := TREAT(V_ARR_LIST.GET(i) AS JSON_OBJECT_T);
            V_OBJECT       := TREAT(V_OBJECT.GET('MAP') AS JSON_OBJECT_T);
            V_KEY_VALUE_LIST     := V_OBJECT.GET_KEYS;
             
            FOR j IN 1 .. V_KEY_VALUE_LIST.COUNT 
            LOOP
                V_WHERE_VALUES := V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(V_SQL);
        OPEN CUR_1 FOR
            V_SELECT || V_TABLE_NAME || V_WHERE || V_WHERE_VALUES;
        
        RETURN;
    END IF;
        
    IF V_ACTIONTYPE = 'C' THEN
        FOR i IN 0..V_ARR_LIST.GET_SIZE-1 LOOP
            V_OBJECT       := TREAT(V_ARR_LIST.GET(i) AS JSON_OBJECT_T);
            V_OBJECT       := TREAT(V_OBJECT.GET('MAP') AS JSON_OBJECT_T);
            V_KEY_VALUE_LIST     := V_OBJECT.GET_KEYS;

            V_SQL := NULL;
            V_COLUMNS := NULL;
            V_INSERT_VALUES := NULL;
            V_SQL := V_INSERT || V_TABLE_NAME || V_OPEN ;             
            FOR j IN 1 .. V_KEY_VALUE_LIST.COUNT 
            LOOP
                IF j <> V_KEY_VALUE_LIST.COUNT THEN 
                    V_COLUMNS       := V_COLUMNS       || V_KEY_VALUE_LIST (j)                                                       || V_COMMA;
                    V_INSERT_VALUES := V_INSERT_VALUES || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT || V_COMMA;
                ELSE 
                    V_COLUMNS       := V_COLUMNS       || V_KEY_VALUE_LIST (j);
                    V_INSERT_VALUES := V_INSERT_VALUES || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
                END IF; 
                
                DBMS_OUTPUT.PUT_LINE (V_KEY_VALUE_LIST(j) || V_EQUAL || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)));
            END LOOP; 
            V_SQL := V_SQL || V_COLUMNS || V_CLOSE || V_VALUES || V_OPEN || V_INSERT_VALUES || V_CLOSE;
            DBMS_OUTPUT.PUT_LINE(V_SQL);
            EXECUTE IMMEDIATE V_SQL;
        END LOOP;
        RETURN;
    END IF;
    
    IF V_ACTIONTYPE = 'U' THEN
        FOR i IN 0..V_ARR_LIST.GET_SIZE-1 LOOP
            V_OBJECT       := TREAT(V_ARR_LIST.GET(i) AS JSON_OBJECT_T);
            V_OBJECT       := TREAT(V_OBJECT.GET('MAP') AS JSON_OBJECT_T);
            V_KEY_VALUE_LIST     := V_OBJECT.GET_KEYS;

            V_SQL := NULL;
            V_COLUMNS := NULL;
            V_UPDATE_SET_VALUES := NULL;
            V_WHERE_VALUES := NULL;
            V_SQL := V_UPDATE || V_TABLE_NAME || V_SET ;             
            FOR j IN 1 .. V_KEY_VALUE_LIST.COUNT 
            LOOP
                IF (TO_NUMBER(V_PK_COUNT) + j) <= V_KEY_VALUE_LIST.COUNT THEN
                    IF (TO_NUMBER(V_PK_COUNT) + j) <> V_KEY_VALUE_LIST.COUNT THEN
                        V_WHERE_VALUES := V_WHERE_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT || V_AND;
                    ELSE 
                        V_WHERE_VALUES := V_WHERE_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
                    END IF;
                ELSE
                    IF j <> V_KEY_VALUE_LIST.COUNT THEN
                        V_UPDATE_SET_VALUES := V_UPDATE_SET_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT || V_COMMA;
                    ELSE 
                        V_UPDATE_SET_VALUES := V_UPDATE_SET_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
                    END IF;
                END IF;
                
                DBMS_OUTPUT.PUT_LINE (V_KEY_VALUE_LIST(j) || V_EQUAL || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)));
            END LOOP;
            V_SQL := V_SQL || V_UPDATE_SET_VALUES || V_WHERE || V_WHERE_VALUES;
            DBMS_OUTPUT.PUT_LINE(V_SQL);
            EXECUTE IMMEDIATE V_SQL;
        END LOOP;
        RETURN;
    END IF;
    
    IF V_ACTIONTYPE = 'D' THEN
        FOR i IN 0..V_ARR_LIST.GET_SIZE-1 LOOP
            V_OBJECT       := TREAT(V_ARR_LIST.GET(i) AS JSON_OBJECT_T);
            V_OBJECT       := TREAT(V_OBJECT.GET('MAP') AS JSON_OBJECT_T);
            V_KEY_VALUE_LIST     := V_OBJECT.GET_KEYS;

            V_SQL := NULL;
            V_DELETE_VALUES := NULL;
            V_SQL := V_DELETE || V_TABLE_NAME || V_WHERE;             
            FOR j IN 1 .. V_KEY_VALUE_LIST.COUNT 
            LOOP
                IF TO_NUMBER(V_PK_COUNT) <= j THEN
                    IF j <> V_KEY_VALUE_LIST.COUNT THEN
                        V_DELETE_VALUES := V_DELETE_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT || V_AND;
                    ELSE 
                        V_DELETE_VALUES := V_DELETE_VALUES || V_KEY_VALUE_LIST(j) || V_EQUAL || V_TEXT_FORMAT || V_OBJECT.GET_STRING(V_KEY_VALUE_LIST(j)) || V_TEXT_FORMAT;
                    END IF;
                END IF;
            END LOOP; 
            V_SQL := V_SQL || V_DELETE_VALUES;
            DBMS_OUTPUT.PUT_LINE(V_SQL);
            EXECUTE IMMEDIATE V_SQL;
        END LOOP;
        RETURN;
    END IF;
    
    IF CUR_1%ISOPEN = FALSE THEN
        OPEN CUR_1 FOR SELECT 1 FROM dual;
    END IF;
    IF CUR_2%ISOPEN = FALSE THEN
        OPEN CUR_2 FOR SELECT 1 FROM dual;
    END IF;
    
    RS_CODE := 'E';
    RS_MSG := 'CHECK ACTION TYPE!';
    
END SP_TEMP_NOT_USE;

/
