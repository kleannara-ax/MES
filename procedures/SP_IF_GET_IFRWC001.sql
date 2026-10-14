
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_GET_IFRWC001" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
  	P_IF_SEQ        IN        VARCHAR2,       --KEY
  	P_MBLNR         IN        VARCHAR2,       --SAP 문서번호
  	P_MJAHR         IN        VARCHAR2,       --SAP 문서번호(년도)
  	P_ZRESULT       IN        VARCHAR2,       --SAP 결과값 Return( S:성공, E:오류 )
	P_IF_MES_KEY    IN        VARCHAR2,       --I/F KEY    
  	P_ZMESSAGE      IN        VARCHAR2,       --SAP결과 메시지
	P_SUCCESS       OUT       VARCHAR2,       --작업성공/실패(Y:성공, N:실패)
	P_RS_LIST       OUT       SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-WCS 밀롤재고이동정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WCS 밀롤재고이동정보 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/05 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/05    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFRWC001]  : (.RU.) WCS 밀롤재고이동정보
 *=============================================================================*/


AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                     -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_GET_IFRWC001';                        -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    V_CNT             NUMBER  DEFAULT 0;
    V_IND_BCD         VARCHAR2(100)       := '';                                  -- 개별바코드
    V_STOR_LOC_CD     VARCHAR2(100)       := '';                                  -- 저장위치    
    V_LOC_CD          VARCHAR2(100)       := '';                                  -- 로케이션 
    V_FROM_STK        VARCHAR2(100)       := '';
   
    --20230203 여한진 WCS 밀롤재고이동정보 로그 남기기
    V_WCS_CNT		  NUMBER	DEFAULT 0;
    V_DOC_NO		  VARCHAR2(30);
BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;


    IF P_TYPE = 'LIST' THEN /*전송데이타 리스트*/
      BEGIN           
      OPEN P_RS_LIST FOR 
          SELECT  K.IF_SEQ        								  --Interface Se
								 ,FN_RECDATE(K.IF_DATE)	IF_DATE	  --I/F 데이터 송
								 ,K.RECV_FLAG                     --수신 시스템 
								 ,K.RECV_ERR_MSG                  --수신 시스템 
								 ,K.RECV_DATE                     --수신 시스템 
								 ,K.WCS_KEY_NO                    --결과번호    
								 ,K.WCS_KEY_SEQ                   --결과순번    
								 ,K.MOVE_DT                       --이동일 (YYYY
								 ,K.BARCODE  AS IND_BCD           --밀롤바코드  
								 ,K.LOT_ID                        --LOT번호(To)    
								 ,K.FROM_STK                      --From지역    
								 ,K.FROM_LOC                      --From위치    
								 ,K.TO_STK                        --To지역      
								 ,K.TO_LOC                        --To위치      
								 ,K.CRAT_DATE AS REGDATE          --등록일시    
								 ,K.CRAT_ID AS REGID              --등록자      
								 ,K.UPDT_DATE AS UPDDATE          --수정일시    
								 ,K.UPDT_ID AS UPDID              --수정자      
								 ,K.REMARK1                       --비고1       
								 ,K.REMARK2                       --비고2       
								 ,K.REMARK3                       --비고3       
								 ,K.REMARK4                       --비고4       
								 ,K.REMARK5                       --비고5       
								 ,K.REMARK6                       --비고6       
								 ,K.REMARK7                       --비고7       
								 ,K.REMARK8                       --비고8       
								 ,K.REMARK9                       --비고9       
								 ,K.REMARK10                      --비고10      
								 ,K.DOC_NO                        --문서번호    
								 ,K.DOC_NOSEQ                     --문서번호 순번
								 ,K.IF_MES_KEY                    --MES Inserfac
								 ,K.MBLNR                         --SAP 문서번호
								 ,K.MJAHR                         --SAP 문서번호
								 ,W.WERKS AS WERKS_FROM           --플랜트(FROM)
								 ,W.WERKS AS WERKS_TO             --플랜트(TO)								 
								 ,W.MATNR                         --자재
								 ,W.MATNR AS MATNR_FROM           --자재번호(From)
								 ,W.MATNR AS MATNR_TO             --자재번호(To)								 								 
								 ,W.STCK_QTY AS MENGE             --수량
								 ,W.UNIT     AS MEINS             --단위
								 ,'311'        AS BWART             --이동유형
								 ,K.LOT_ID   AS CHARG_FROM        --LOT번호(FROM) 
								 ,K.LOT_ID   AS CHARG_TO          --LOT번호(TO) 								 
								 ,(SELECT STOR_LOC_CD FROM TB_MAS003 WHERE WCS_STOR_LOC_CD = K.FROM_STK AND ROWNUM=1) AS LGORT_FROM --저장위치(FROM) 
								 ,(SELECT STOR_LOC_CD FROM TB_MAS003 WHERE WCS_STOR_LOC_CD = K.TO_STK AND ROWNUM=1) AS LGORT_TO			--자정위치(TO)		
								 ,NVL(O.VBELN,'')    AS VBELN_FROM       --판매문서
								 ,NVL(O.POSNR,'')    AS POSNR_FROM       --판매문서 항목번호
								 ,NVL(O.VBELN,'')    AS VBELN_TO         --판매문서
								 ,NVL(O.POSNR,'')    AS POSNR_TO	        --판매문서 항목번호
          FROM TB_IFRWC001 K
              ,TB_INV001 W 
              ,TB_WRK002 S
              ,TB_SCH016 O
          WHERE K.BARCODE = W.IND_BCD(+)
          AND K.BARCODE = S.IND_BCD(+)
          AND S.WRK_ORDR_NO = O.WRK_ORDR_NO(+)
          AND S.WRK_ORDR_SEQNO = O.WRK_ORDR_SEQNO(+)                                                 
          AND K.RECV_FLAG IN('N') 
          --AND K.FROM_STK <> K.TO_STK  --잠시사용함. 꼭 이줄삭제 해야 함.!!!!!! (JAVA에서 FROM,TO가 동일하면 성공한것처럼 넘기면 재고이동 처리 되게 하고 이줄 삭제 해야 함.)
          --AND K.FROM_STK <> '*'
          --AND K.RECV_FLAG IN('N','E')            
          ; --재고에 개별바코드가 100%존재해야 플랜트,자재,수량,단위를 가져올수있다.. 꼭 기억하자..        

      P_SUCCESS           := 'Y';

      EXCEPTION           
      WHEN OTHERS THEN 
        P_SUCCESS           := 'N';

        --E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := 'EXCEPTION LIST ERROR. [' || SQLCODE || ']' || SUBSTR(SQLERRM,1,500);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_PRG_NM);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
      END;    
    ELSIF P_TYPE = 'SAVE' THEN
      BEGIN
        UPDATE TB_IFRWC001
        SET  MBLNR        = P_MBLNR
            ,MJAHR        = P_MJAHR
            ,RECV_FLAG    = P_ZRESULT
            ,RECV_ERR_MSG = SUBSTRB(P_ZMESSAGE,1,200)
            ,RECV_DATE    = SYSDATE
            ,IF_MES_KEY   = P_IF_MES_KEY             
        WHERE IF_SEQ  = P_IF_SEQ;
        
        --------------------------------------------------------------------------------------------------------------------
        --공정재고 
        --------------------------------------------------------------------------------------------------------------------
        IF P_ZRESULT = 'S' THEN 
          SELECT BARCODE,(SELECT STOR_LOC_CD FROM TB_MAS003 WHERE WCS_STOR_LOC_CD = TO_STK AND ROWNUM=1), 
                 CASE WHEN TO_STK = 'M' THEN 'L2900' ELSE TO_LOC END, FROM_STK
          INTO V_IND_BCD, V_STOR_LOC_CD, V_LOC_CD, V_FROM_STK
          FROM TB_IFRWC001
          WHERE IF_SEQ  = P_IF_SEQ;      

          --TB_INV001:공정재고
          SELECT COUNT(WERKS) INTO V_CNT 
          FROM TB_INV001 
          WHERE IND_BCD = V_IND_BCD;     

          --창고위치UPDATE
          IF V_CNT > 0 THEN                  
            UPDATE TB_INV001
            SET STOR_LOC_CD = V_STOR_LOC_CD
               ,LOC_CD = V_LOC_CD
               ,MR_WH_YN = CASE WHEN V_FROM_STK = 'A' OR MR_WH_YN = 'Y' THEN 'Y' 
                                ELSE 'N' END
               ,UPDDATE = sysdate                                        --수정일자
               ,UPDID = 'IFRWC001'                                         --수정자             
            WHERE IND_BCD = V_IND_BCD;                                                                                                                               
          END IF;   
        END IF;                      
        --------------------------------------------------------------------------------------------------------------------
       
        --20230203 여한진 WCS 밀롤재고이동정보 이력 남기기
        BEGIN
	        SELECT BARCODE	INTO V_IND_BCD
	          FROM TB_IFRWC001_HIS tih
	         WHERE IF_SEQ = P_IF_SEQ;
	        
	        V_WCS_CNT	:= 1;
	    EXCEPTION
	    	WHEN NO_DATA_FOUND THEN
	    		V_WCS_CNT	:= 0;
	    END;
	   
	    IF V_WCS_CNT = 0 THEN
	    	V_DOC_NO	:=	FN_GET_MDOCNO('M', 'IF860');
	    	
	    	INSERT INTO TB_IFRWC001_HIS (IF_SEQ, IF_DATE, RECV_FLAG, RECV_ERR_MSG, RECV_DATE
	    							   , WCS_KEY_NO, WCS_KEY_SEQ, MOVE_DT, BARCODE, LOT_ID, FROM_STK, FROM_LOC
	    							   , TO_STK, TO_LOC, CRAT_DATE, CRAT_ID, DOC_NO, DOC_NOSEQ, IF_MES_KEY, MBLNR, MJAHR)
	    						  SELECT IF_SEQ, IF_DATE, P_ZRESULT, SUBSTRB(P_ZMESSAGE,1,200), SYSDATE
	    						  	   , WCS_KEY_NO, WCS_KEY_SEQ, MOVE_DT, BARCODE, LOT_ID, DECODE(FROM_STK, 'M', '2000', 'B', '2700', FROM_STK), FROM_LOC
	    						  	   , DECODE(TO_STK, 'M', '2000', 'B', '2700', TO_STK), TO_LOC, SYSDATE, 'sp_ifrwc001', V_DOC_NO, '1', P_IF_MES_KEY, P_MBLNR, P_MJAHR
	    						  	FROM TB_IFRWC001
	    						   WHERE IF_SEQ = P_IF_SEQ;
	    END IF;
        P_SUCCESS := 'Y';
        COMMIT;

      EXCEPTION
      WHEN OTHERS THEN
        P_SUCCESS           := 'N';

        --E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION SAVE ERROR. [' || SQLCODE || ']' || SUBSTR(SQLERRM,1,500);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_PRG_NM);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
      END;
    END IF;
END;
/
