--------------------------------------------------------
--  DDL for Procedure SP_POP_PS_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_PS_UPDATE" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
)
AS 
   V_DUMMY   NUMBER ;
BEGIN
  BEGIN


                -- TB_IFS004  MSDATE
                FOR K IN (
                            SELECT
                                    A.MSDATE                               MSDATE  	,
                                    TO_CHAR(B.PRD_STR_DATE, 'YYYY-MM-DD')  PRD_STR_DATE,
                                    A.MDOCNO                               MDOCNO,          
                                    A.MDOCSEQ                              MDOCSEQ,         
                                    A.AUFNR                                AUFNR 
                                FROM 
                                    TB_IFS004   A,
                                    TB_WRK002   B
                                WHERE A.MDOCNO 	        =   B.DOC_NO       AND 
                                      A.MDOCSEQ	        =   B.DOC_SEQNO    AND
                                      A.AUFNR           =  B.ORDER_NO      AND  
                                      A.MSDATE          IS NULL            AND
                                      B.PRD_STR_DATE    IS NOT NULL         ) 
                LOOP
                  UPDATE TB_IFS004  SET MSDATE = K.PRD_STR_DATE
                  WHERE MDOCNO 	        =  K.MDOCNO     AND 
                        MDOCSEQ	        =  K.MDOCSEQ    AND
                        AUFNR           =  K.AUFNR      ;

                END LOOP;
                
                -- TB_IFS004  MEDATE
                FOR K IN (
                            SELECT
                                    A.MEDATE                               MEDATE  	,
                                    TO_CHAR(B.PRD_END_DATE, 'YYYY-MM-DD')  PRD_END_DATE,
                                    A.MDOCNO                               MDOCNO,          
                                    A.MDOCSEQ                              MDOCSEQ,         
                                    A.AUFNR                                AUFNR 
                                FROM 
                                    TB_IFS004   A,
                                    TB_WRK002   B
                                WHERE A.MDOCNO 	        =   B.DOC_NO       AND 
                                      A.MDOCSEQ	        =   B.DOC_SEQNO    AND
                                      A.AUFNR           =   B.ORDER_NO     AND  
                                      A.MEDATE          IS NULL            AND
                                      B.PRD_END_DATE    IS NOT NULL         ) 
                LOOP
                  UPDATE TB_IFS004  SET MEDATE = K.PRD_END_DATE
                  WHERE MDOCNO 	        =  K.MDOCNO     AND 
                        MDOCSEQ	        =  K.MDOCSEQ    AND
                        AUFNR           =  K.AUFNR      ;

                END LOOP;

                -- TB_IFS004  MSTIME
                FOR K IN (
                            SELECT
                                    A.MSTIME                               MEDATE  	,
                                    TO_CHAR(B.PRD_STR_DATE, 'HH24:MI:SS')  PRD_STR_DATE,
                                    A.MDOCNO                               MDOCNO,          
                                    A.MDOCSEQ                              MDOCSEQ,         
                                    A.AUFNR                                AUFNR 
                                FROM 
                                    TB_IFS004   A,
                                    TB_WRK002   B
                                WHERE A.MDOCNO 	        =   B.DOC_NO       AND 
                                      A.MDOCSEQ	        =   B.DOC_SEQNO    AND
                                      A.AUFNR           =   B.ORDER_NO     AND  
                                      A.MSTIME          IS NULL            AND
                                      B.PRD_STR_DATE    IS NOT NULL         ) 
                LOOP
                  UPDATE TB_IFS004  SET MSTIME = K.PRD_STR_DATE
                  WHERE MDOCNO 	        =  K.MDOCNO     AND 
                        MDOCSEQ	        =  K.MDOCSEQ    AND
                        AUFNR           =  K.AUFNR      ;

                END LOOP;

                -- TB_IFS004  MRUNTIME
                FOR K IN (
                            SELECT
                                    A.MRUNTIME                             MRUNTIME  	,
                                    TO_CHAR(B.TM)                          TM,
                                    A.MDOCNO                               MDOCNO,          
                                    A.MDOCSEQ                              MDOCSEQ,         
                                    A.AUFNR                                AUFNR 
                                FROM 
                                    TB_IFS004   A,
                                    TB_WRK002   B
                                WHERE A.MDOCNO 	        =   B.DOC_NO       AND 
                                      A.MDOCSEQ	        =   B.DOC_SEQNO    AND
                                      A.AUFNR           =   B.ORDER_NO     AND  
                                      A.MRUNTIME        =   '0'            AND
                                      B.TM              > 0          
                           ) 
                LOOP
                  UPDATE TB_IFS004  SET MRUNTIME = K.TM
                  WHERE MDOCNO 	        =  K.MDOCNO     AND 
                        MDOCSEQ	        =  K.MDOCSEQ    AND
                        AUFNR           =  K.AUFNR      ;

                END LOOP;



                COMMIT;  
    --예외처리(catch)
    END;
END;

/
