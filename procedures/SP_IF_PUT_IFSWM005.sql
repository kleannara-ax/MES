
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWM005" (
	P_TYPE          IN        VARCHAR2,       --LIST,  SAVE
  	P_DOCNO         IN        VARCHAR2,       --MES문서번호
  	P_DOCSEQ        IN        VARCHAR2,       --MES문서순번
  	P_IF_STATUS     IN        VARCHAR2,       --결과값 Return( S:성공, E:오류 )
  	P_IF_ERR_MESS   IN        VARCHAR2,       --결과 메시지
	P_IF_MES_KEY    IN        VARCHAR2,       --I/F KEY  
	P_SUCCESS       OUT       VARCHAR2,       --작업성공/실패(Y:성공, N:실패)
	P_RS_LIST       OUT       SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-완제품 출고 요청 정보
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 완제품 출고 요청 정보 정보 데이타 전송
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES->WMS
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/18    1.0.0   강현주         Initial Version
 *2022/08/05     1.0.1   강현주         정상입고,출고취소,오류시 Flag값 처리 삽입 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFSWM005]  : (.RU.) 완제품 출고 요청 정보
 *=============================================================================*/

AS

    V_PLT_CD          VARCHAR2(100)  := 'I/F';                                     -- 단위업무
    V_PRG_NM          VARCHAR2(100)  := 'SP_IF_PUT_IFSWM005';                        -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    V_IND_BCD         VARCHAR2(100)       := ''; 
    V_DLFL            VARCHAR2(10);
	V_WERKS			  VARCHAR2(10);

	-- 2022-12-26(월요일) 안상현, WMS 입고요청, 입고요청취소 ROLLBACK 적용을 위한 설비코드 변수
	V_MACH_CD			VARCHAR2(10);	--설비코드

	-- 20230126 여한진 로그 남기기 위해 체크하는 변수
	V_HISTORY_FLAG		VARCHAR2(1) 	:= 'Y';
	V_LOT_NO			TB_WRK021.LOT_NO%TYPE;

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;


    IF P_TYPE = 'LIST' THEN /*전송데이타 리스트*/
      BEGIN           
      OPEN P_RS_LIST FOR 
          SELECT DOC_NO      											--MES 문서번호               
                ,DOC_SEQNO                        --MES 문서순번          
                ,MATNR                            --품목코드              
                ,QTY                              --입고 요청량            
                ,UNIT                             --단위                
                ,ORDER_NO                         --생산오더번호(SAP)       
                ,ORDER_SEQNO                      --생산오더번호 순번(SAP)    
                ,DLFL                             --삭제 지시자(불출요청)      
                ,STOR_LOC_TO                      --저장위치(WMS창고) TO    
                ,WERKS                            --플랜트               
                ,PACK_TYPE                        --포장 타입             
                ,MACHINE                          --생산호기              
                ,NTN_CD                           --국가코드              
                ,KUNNR                            --판매처(납품처)          
                ,PRDC_DT                          --제조일자              
                ,RCVGDS_DT                        --입고일자              
                ,DSTBT_DDLIN                      --유통기한 (생리대,기저귀,물티슈)
                ,IND_BCD                          --개별바코드 (협력업체바코드)   
                ,LOT_NO                           --LOT번호             
                ,WEIGHT                           --평량                
                ,CON_TYPE                         --컨테이너 타입           
                ,CORE                             --지관                
                ,STCK_NO                          --특별재고번호            
                ,EMPLY_NO                         --작업자ID             
                ,EMPLY_NM                         --작업자명              
                ,STOR_LOC_FROM                    --저장위치(MES창고) FROM  
                ,PCODE                            --지종                
                ,WLEN                             --가로길이              
                ,VLEN                             --세로길이              
                ,LPAD(OVBELN,10,'0')  AS OVBELN    --판매문서              
                ,LPAD(OPOSNR,6,'0')   AS OPOSNR    --판매문서 항목번호         
                ,SAUART                           --판매문서 유형
                ,REQ_DT                             --오더일자
          FROM TB_IFSWM005
          WHERE IF_STATUS IN('N')
            AND DOC_NO = P_DOCNO
          --WHERE IF_STATUS IN('N','E')
      ;

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
	    BEGIN  
		    SELECT A.IND_BCD INTO V_IND_BCD
              FROM(
                    SELECT IND_BCD 
                      FROM TB_IFSWM005 ti 
                     WHERE DOC_NO = P_DOCNO
                       AND DOC_SEQNO = P_DOCSEQ
                       -- 2022-12-27(화요일) 안상현, MES <-> WMS 인터페이스(입고요청, 입고요청취소)를 쿼리 수정 AND ROWNUM = 1;
                       AND NVL(IF_STATUS,'N') IN('N')
                      ORDER BY IF_GET_DATE DESC
                     ) A
              WHERE ROWNUM = 1       
              ;
	    EXCEPTION WHEN NO_DATA_FOUND THEN
	    	V_IND_BCD := '';
	    END;

	    IF V_IND_BCD <> '' THEN
	    	UPDATE TB_IFSWM005
	           SET IF_STATUS    = P_IF_STATUS
	           	  ,IF_ERR_MESS  = P_IF_ERR_MESS
	              ,IF_SET_DATE  = SYSDATE
	              ,IF_MES_KEY   = P_IF_MES_KEY
	         WHERE IND_BCD = V_IND_BCD
	           AND IF_STATUS = 'N'
	           AND DOC_NO <> P_DOCNO;
	    END IF;

        UPDATE TB_IFSWM005
           SET IF_STATUS    = P_IF_STATUS
           	  ,IF_ERR_MESS  = P_IF_ERR_MESS
              ,IF_SET_DATE  = SYSDATE
              ,IF_MES_KEY   = P_IF_MES_KEY
         WHERE DOC_NO    = P_DOCNO
           AND DOC_SEQNO = P_DOCSEQ
           -- 2022-12-27(화요일) 안상현, MES <-> WMS 인터페이스(입고요청, 입고요청취소)를 쿼리 수정 AND ROWNUM = 1;
           AND NVL(IF_STATUS,'N') IN('N');

        --P_DOCNO,P_DOC_SEQ 중복발생할수 있어서 수정함. C 처리후 D 처리시 중복발생함.
        SELECT K.IND_BCD, K.DLFL, K.WERKS, K.LOT_NO INTO V_IND_BCD, V_DLFL, V_WERKS, V_LOT_NO
        FROM (
          SELECT IND_BCD, DLFL, WERKS, LOT_NO
          FROM TB_IFSWM005
          WHERE DOC_NO    = P_DOCNO
          AND   DOC_SEQNO = P_DOCSEQ
          ORDER BY IF_GET_DATE DESC
        ) K
        WHERE ROWNUM = 1;
        --YSH 2022.08.07

        --2022-12-26(월요일) 안상현, WMS 입고요청, 입고요청취소 ROLLBACK 적용
        --수정전 프로시저 : SP_IF_PUT_IFSWM005_AN_BACK
		IF V_WERKS <> 'P100' THEN

			-- 설비코드
			SELECT 
				MACH_CD			-- 설비 코드
		    INTO 
		    	V_MACH_CD		-- 설비 코드
			FROM 
				TB_WRK001
			WHERE 1=1
			AND WERKS = V_WERKS
			AND IND_BCD = V_IND_BCD;

	        IF P_IF_STATUS = 'S' THEN --성공
	        	-- 입고요청 성공 시, UPDATE 필요없음(이미 WEB에서 상태를 변경해서 넘어온다.)
	        	IF V_DLFL = 'D' THEN --입고요청 취소 
	        		-- 설비코드가 화장지(합지, 가공, 예외생산)인 경우 : 생산여부 제외 UPDATE
	        		IF SUBSTR(V_MACH_CD, 1, 3) = 'TAA' OR SUBSTR(V_MACH_CD, 1, 3) = 'TRA' OR SUBSTR(V_MACH_CD, 1, 3) = 'TPG' THEN
	        			UPDATE 
		                    TB_WRK001
		                SET 
		                	CHK_PP_DATE = NULL      -- 생산확인일시(현재일시)
		                ,   CHK_PP_ID = NULL  		-- 생산확인자
		                WHERE WERKS = V_WERKS   	-- 플랜트 코드
		                AND MACH_CD = V_MACH_CD 	-- 설비 코드
		                AND IND_BCD = V_IND_BCD;	-- 개별 바코드
		            ELSE
	        		-- 설비코드가 화장지(합지, 가공, 예외생산)가 아닌 경우 : 품질여부 UPDATE
	        			UPDATE 
		                    TB_WRK001
		                SET 
		                    CHK_QC_YN = 'N'			-- 품질확인여부
		                ,   CHK_QC_DATE = NULL      -- 품질확인일시(현재일시)
		                ,   CHK_QC_ID = NULL  		-- 품질확인자
		                WHERE WERKS = V_WERKS   	-- 플랜트 코드
		                AND MACH_CD = V_MACH_CD 	-- 설비 코드
		                AND IND_BCD = V_IND_BCD; 	-- 개별 바코드
	        		END IF;

	        		-- 설비코드와 상관없이 재고 상태 UPDATE
	        		UPDATE 
	                    TB_INV001
	                SET 
	                    STCK_STA = '00' 		-- 재고상태(00:정상, 10:투입, 20:생산실적, 25:등급변경, 30:불용, 40:부적합, 50:폐기, 60:보류, 70:출고, 80:요청)
	                WHERE WERKS = V_WERKS 		-- 플랜트 코드
	                AND MACH_CD = V_MACH_CD 	-- 설비 코드
	                AND IND_BCD = V_IND_BCD; 	-- 개별 바코드

	                -- TB_WRK015(완제품 출고 정보) TABLE UPDATE
	                UPDATE 
	                	TB_WRK015
                   	SET DLFL = 'D'
                 	WHERE 1=1
                 	AND WERKS = V_WERKS
                   	AND IND_BCD = V_IND_BCD
					AND DLFL = 'C';
                ELSIF V_DLFL = 'C' THEN -- 입고요청시 요청으로 변경 
	        		-- 설비코드와 상관없이 재고 상태 UPDATE
	        		UPDATE 
	                    TB_INV001
	                SET 
	                    STCK_STA = '80' 		-- 재고상태(00:정상, 10:투입, 20:생산실적, 25:등급변경, 30:불용, 40:부적합, 50:폐기, 60:보류, 70:출고, 80:요청)
	                WHERE WERKS = V_WERKS 		-- 플랜트 코드
	                AND MACH_CD = V_MACH_CD 	-- 설비 코드
	                AND IND_BCD = V_IND_BCD; 	-- 개별 바코드
	        	END IF;

	        ELSIF P_IF_STATUS <> 'S' THEN --실패
	        	-- 입고요청취소 실패 시, 아무 행위도 하지 않으면 된다.
	        	IF V_DLFL = 'C' THEN -- 입고요청시 에러 -> 정상상태로 ROLLBACK
	        		-- 설비코드가 화장지(합지, 가공, 예외생산)인 경우 : 생산여부 제외 UPDATE

	        		IF SUBSTR(V_MACH_CD, 1, 3) <> 'TAA' AND SUBSTR(V_MACH_CD, 1, 3) <> 'TRA' AND SUBSTR(V_MACH_CD, 1, 3) <> 'TPG' THEN
	        		-- 설비코드가 화장지(합지, 가공, 예외생산)가 아닌 경우 : 품질여부 UPDATE
	        			UPDATE 
		                    TB_WRK001
		                SET 
		                    CHK_QC_YN = 'N'			-- 품질확인여부
		                ,   CHK_QC_DATE = NULL      -- 품질확인일시(현재일시)
		                ,   CHK_QC_ID = NULL  		-- 품질확인자
		                WHERE WERKS = V_WERKS   	-- 플랜트 코드
		                AND MACH_CD = V_MACH_CD 	-- 설비 코드
		                AND IND_BCD = V_IND_BCD; 	-- 개별 바코드

	        		END IF;

	        		-- 설비코드와 상관없이 재고 상태 UPDATE
	        		UPDATE 
	                    TB_INV001
	                SET 
	                    STCK_STA = '00' 		-- 재고상태(00:정상, 10:투입, 20:생산실적, 25:등급변경, 30:불용, 40:부적합, 50:폐기, 60:보류, 70:출고, 80:요청)
	                WHERE WERKS = V_WERKS 		-- 플랜트 코드
	                AND MACH_CD = V_MACH_CD 	-- 설비 코드
	                AND IND_BCD = V_IND_BCD; 	-- 개별 바코드

	        	END IF;

	        END IF;

	    -- P100일 경우
		ELSE
			--20230126 여한진 PS제지일 경우 WMS출고요청 로그 남기기
			IF V_HISTORY_FLAG = 'Y' THEN
				IF V_DLFL = 'C' THEN
			    	INSERT INTO OUT_REQ_HISTORY (IND_BCD, LOT_NO, RESULTMSG, REGDATE)
			    						VALUES(V_IND_BCD, V_LOT_NO, '(WMS 출고요청결과) ' || P_IF_ERR_MESS, SYSDATE);
			    -- 출고요청취소
			   	ELSE
			    	INSERT INTO OUT_REQ_HISTORY (IND_BCD, LOT_NO, RESULTMSG, REGDATE)
			    						VALUES(V_IND_BCD, V_LOT_NO, '(WMS 출고요청취소결과) ' || P_IF_ERR_MESS, SYSDATE);

			    	-- 2023-01-26(목요일) 안상현, 출고요청취소 2회 클릭 시, 에러 방지 및 롤백처리
			    	IF P_IF_STATUS = 'S' THEN
	                    UPDATE 
	                        TB_WRK015
	                    SET 
	                        DLFL = 'D'
	                    WHERE 1=1
	                    AND DOC_NO = P_DOCNO
	                    AND DOC_SEQNO = P_DOCSEQ;
					END IF;

			    END IF;
       		END IF;
	    END IF;

        P_SUCCESS := 'Y';
        COMMIT;

      /*EXCEPTION
      WHEN OTHERS THEN
        P_SUCCESS           := 'N';

        --E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION SAVE ERROR. [' || SQLCODE || ']' || SUBSTR(SQLERRM,1,500);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_PRG_NM);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
*/
      END;
    END IF;

END;
/
