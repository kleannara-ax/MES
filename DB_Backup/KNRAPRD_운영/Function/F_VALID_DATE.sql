--------------------------------------------------------
--  DDL for Function F_VALID_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."F_VALID_DATE" 
(
    P_STR_DATE    IN VARCHAR2
   ,P_DATE_FORMAT IN VARCHAR2
)
 RETURN VARCHAR 
IS
    v_returnValue VARCHAR2(100);
    v_date        DATE;
BEGIN
    -- 00. Initialize
    v_returnValue := 'TRUE';

    -- 01. Validation
    IF P_STR_DATE IS NULL THEN
        v_returnValue := 'Parameter [1:P_STR_DATE] is null.';
    END IF;

    IF P_DATE_FORMAT IS NULL THEN
        v_returnValue := 'Parameter [2:P_DATE_FORMAT] is null.';
    END IF;

    -- 02. Check Logic
    IF v_returnValue = 'TRUE' THEN
        BEGIN
            v_date := TO_DATE(P_STR_DATE, P_DATE_FORMAT);
        EXCEPTION
            WHEN OTHERS THEN
                v_returnValue := 'FALSE [1:P_STR_DATE:' || P_STR_DATE || '] [2:P_DATE_FORMAT:' || P_DATE_FORMAT || ']';
        END;
    END IF;

    -- 99. Return Result
    RETURN v_returnValue;
    
END;

/
